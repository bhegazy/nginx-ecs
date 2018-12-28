variable "name" {}
variable "environment" {}
variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "ecs_cluster" {}
variable "desired_count" {}
variable "iam_role" {}

variable "blue_port" {
  default = 80
}

variable "green_port" {
  default = 8080
}

variable "docker_image" {}

variable "region" {}
