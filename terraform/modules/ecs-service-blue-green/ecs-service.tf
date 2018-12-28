resource "aws_ecs_service" "blue-service" {
  name            = "${var.name}-${var.environment}-blue"
  cluster         = "${var.ecs_cluster}"
  task_definition = "${aws_ecs_task_definition.blue-task.arn}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${var.iam_role}"

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.blue-tg.arn}"
    container_name   = "${var.name}-${var.environment}-blue"
    container_port   = "${var.blue_port}"
  }

  depends_on = ["aws_alb.alb", "aws_alb_target_group.blue-tg", "aws_ecs_task_definition.blue-task"]
}

resource "aws_ecs_service" "green-service" {
  name            = "${var.name}-${var.environment}-green"
  cluster         = "${var.ecs_cluster}"
  task_definition = "${aws_ecs_task_definition.green-task.arn}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${var.iam_role}"

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.green-tg.arn}"
    container_name   = "${var.name}-${var.environment}-green"
    container_port   = "${var.green_port}"
  }

  depends_on = ["aws_alb.alb", "aws_alb_target_group.green-tg", "aws_ecs_task_definition.green-task"]
}
