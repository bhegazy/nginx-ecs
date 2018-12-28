resource "aws_cloudwatch_log_group" "ecs-task" {
  name = "${var.name}-${var.environment}-lg"
}

data "template_file" "task" {
  template = "${file("${path.module}/templates/task_def.json")}"

  vars {
    image          = "${var.docker_image}"
    log_group      = "${aws_cloudwatch_log_group.ecs-task.name}"
    name           = "${var.name}-${var.environment}"
    container_port = "${var.container_port}"
    region         = "${var.region}"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.name}-${var.environment}"
  container_definitions    = "${data.template_file.task.rendered}"
  requires_compatibilities = ["EC2"]
  network_mode             = "host"
  cpu                      = "128"
  memory                   = "128"
}
