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
    target_group_arn = "${aws_alb_target_group.default.arn}"
    container_name   = "${var.name}-${var.environment}"
    container_port   = "${var.container_port}"
  }

  depends_on = ["aws_alb.alb", "aws_alb_target_group.default"]
}
