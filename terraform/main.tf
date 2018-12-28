terraform {
  backend "s3" {
    key     = "poc/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 1.35.0"
  region  = "${var.region}"
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

variable "region" {
  default = "ap-southeast-1"
}

data "aws_availability_zones" "all" {}

data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ecs-key" {
  key_name   = "${var.key_name}"
  public_key = "${var.ssh_pubkey_file}"
}

/* this module is using verified module from
   https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
*/
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "main-vpc"
  cidr               = "10.80.0.0/16"
  azs                = ["${data.aws_availability_zones.all.names}"]
  private_subnets    = ["${split(",", var.private_subnets)}"]
  public_subnets     = ["${split(",", var.public_subnets)}"]
  enable_nat_gateway = true
  single_nat_gateway = false

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
  ami                = "${data.aws_ami.ecs_ami.image_id}"
}

module "demo-prod-ecs" {
  source = "./modules/ecs"

  name               = "demo-prod"
  vpc_id             = "${module.vpc.vpc_id}"
  vpc_cidr           = "${module.vpc.vpc_cidr_block}"
  private_subnet_ids = "${join(",", module.vpc.private_subnets)}"
  key_name           = "${var.key_name}"
  ami                = "${data.aws_ami.ecs_ami.image_id}"
}

module "nginx-ecr" {
  source = "./modules/ecr"

  image_name = "nginx"
}

module "nginx-ecs-staging-svc" {
  source = "./modules/ecs-service"

  name              = "nginx"
  environment       = "staging"
  region            = "${var.region}"
  vpc_id            = "${module.vpc.vpc_id}"
  ecs_cluster       = "${module.demo-staging-ecs.ecs_cluster_arn}"
  desired_count     = 1
  iam_role          = "${module.demo-staging-ecs.ecs_iam_role}"
  public_subnet_ids = "${join(",", module.vpc.public_subnets)}"
  docker_image      = "${module.nginx-ecr.ecr_url}"
}

module "nginx-ecs-prod-svc" {
  source = "./modules/ecs-service-blue-green"

  name              = "nginx"
  environment       = "prod"
  region            = "${var.region}"
  vpc_id            = "${module.vpc.vpc_id}"
  ecs_cluster       = "${module.demo-prod-ecs.ecs_cluster_arn}"
  desired_count     = 1
  iam_role          = "${module.demo-prod-ecs.ecs_iam_role}"
  public_subnet_ids = "${join(",", module.vpc.public_subnets)}"
  docker_image      = "${module.nginx-ecr.ecr_url}"
}
