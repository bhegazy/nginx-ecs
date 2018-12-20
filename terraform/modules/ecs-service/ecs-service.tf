variable "name" {}
variable "environment" {}
variable "ecs_cluster" {}
variable "task_def_arn" {}
variable "desired_count" {}
variable "iam_role" {}
variable "lb_target_group_arn" {}

variable "container_port" {
  default = 80
}

resource "aws_ecs_service" "service" {
  name            = "${var.name}-${var.environment}-service"
  cluster         = "${var.ecs_cluster}"
  task_definition = "${var.task_def_arn}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${var.iam_role}"

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${var.lb_target_group_arn}"
    container_name   = "${var.name}-${var.environment}"
    container_port   = "${var.container_port}"
  }
}
