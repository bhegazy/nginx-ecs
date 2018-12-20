variable "name" {}
variable "environment" {}
variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "ecs_cluster" {}
variable "task_def_arn" {}
variable "desired_count" {}
variable "iam_role" {}

variable "container_port" {
  default = 80
}
