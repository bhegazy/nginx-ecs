terraform {
  backend "s3" {
    bucket  = "bill-poc-terraform-state"
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

# Create elastic ip's for nat gateway
resource "aws_eip" "nat" {
  count = 3

  vpc = true
}

/* this module is using verified module from
   https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
*/
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "main-vpc"
  cidr = "10.80.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.80.1.0/24", "10.80.3.0/24", "10.80.5.0/24"]
  public_subnets  = ["10.80.2.0/24", "10.80.4.0/24", "10.80.6.0/24"]

  enable_nat_gateway  = true
  single_nat_gateway  = false
  reuse_nat_ips       = true
  external_nat_ip_ids = ["${aws_eip.nat.*.id}"]

  tags = {
    Terraform   = "true"
    Environment = "poc"
  }
}
