terraform {
  backend "s3" {
    key     = "poc/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 1.35.0"
  region  = "ap-southeast-1"
}

provider "template" {
  version = "~> 1.0.0"
}

provider "null" {
  version = "~> 1.0.0"
}

variable "ssh_pubkey_file" {}

variable "key_name" {
  default = "ecs-key"
}

variable "private_subnets" {
  default = "10.80.1.0/24,10.80.3.0/24,10.80.5.0/24"
}

variable "public_subnets" {
  default = "10.80.2.0/24,10.80.4.0/24,10.80.6.0/24"
}

resource "aws_key_pair" "ecs-key" {
  key_name   = "${var.key_name}"
  public_key = "${var.ssh_pubkey_file}"
}

resource "aws_eip" "nat" {
  count = 3
  vpc   = true
}

/* this module is using verified module from
   https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
*/
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                = "main-vpc"
  cidr                = "10.80.0.0/16"
  azs                 = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets     = ["${split(",", var.private_subnets)}"]
  public_subnets      = ["${split(",", var.public_subnets)}"]
  enable_nat_gateway  = true
  single_nat_gateway  = false
  reuse_nat_ips       = true
  external_nat_ip_ids = ["${aws_eip.nat.*.id}"]

  tags = {
    Name        = "poc"
    Environment = "poc"
  }
}

module "demo-staging-ecs" {
  source = "./modules/ecs"

  name               = "demo-staging"
  vpc_id             = "${module.vpc.vpc_id}"
  vpc_cidr           = "${module.vpc.vpc_cidr_block}"
  private_subnet_ids = "${join(",", module.vpc.private_subnets)}"
  key_name           = "${var.key_name}"
  ami                = "ami-050865a806e0dae53"                    # ap-southeast-1
}

module "demo-prod-ecs" {
  source = "./modules/ecs"

  name               = "demo-prod"
  vpc_id             = "${module.vpc.vpc_id}"
  vpc_cidr           = "${module.vpc.vpc_cidr_block}"
  private_subnet_ids = "${join(",", module.vpc.private_subnets)}"
  key_name           = "${var.key_name}"
  ami                = "ami-050865a806e0dae53"                    # ap-southeast-1
}

module "nginx-ecr" {
  source = "./modules/ecr"

  image_name = "nginx"
}

module "nginx-ecs-staging-td" {
  source = "./modules/ecs-task-def"

  name         = "nginx"
  environment  = "staging"
  docker_image = "${module.nginx-ecr.ecr_url}"
}

module "nginx-ecs-staging-svc" {
  source = "./modules/ecs-service"

  name              = "nginx"
  environment       = "staging"
  vpc_id            = "${module.vpc.vpc_id}"
  ecs_cluster       = "${module.demo-staging-ecs.ecs_cluster_arn}"
  task_def_arn      = "${module.nginx-ecs-staging-td.ecs_td_arn}"
  desired_count     = 1
  iam_role          = "${module.demo-staging-ecs.ecs_iam_role}"
  public_subnet_ids = "${join(",", module.vpc.public_subnets)}"
}

module "nginx-ecs-prod-td" {
  source = "./modules/ecs-task-def"

  name         = "nginx"
  environment  = "prod"
  docker_image = "${module.nginx-ecr.ecr_url}"
}

module "nginx-ecs-prod-svc" {
  source = "./modules/ecs-service"

  name              = "nginx"
  environment       = "prod"
  vpc_id            = "${module.vpc.vpc_id}"
  ecs_cluster       = "${module.demo-prod-ecs.ecs_cluster_arn}"
  task_def_arn      = "${module.nginx-ecs-prod-td.ecs_td_arn}"
  desired_count     = 1
  iam_role          = "${module.demo-prod-ecs.ecs_iam_role}"
  public_subnet_ids = "${join(",", module.vpc.public_subnets)}"
}
