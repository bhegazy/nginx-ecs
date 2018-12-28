resource "aws_cloudwatch_log_group" "ecs-task" {
  name = "${var.name}-${var.environment}-lg"
}

data "template_file" "blue-task-template" {
  template = "${file("${path.module}/templates/task_def.json")}"

  vars {
    image          = "${var.docker_image}"
    log_group      = "${aws_cloudwatch_log_group.ecs-task.name}"
    name           = "${var.name}-${var.environment}-blue"
    container_port = 80
    host_port      = "${var.blue_port}"
    region         = "${var.region}"
  }
}

resource "aws_ecs_task_definition" "blue-task" {
  family                   = "${var.name}-${var.environment}-blue"
  container_definitions    = "${data.template_file.blue-task-template.rendered}"
  requires_compatibilities = ["EC2"]
  network_mode             = "host"
  cpu                      = "128"
  memory                   = "128"
}

data "template_file" "green-task-template" {
  template = "${file("${path.module}/templates/task_def.json")}"

  vars {
    image          = "${var.docker_image}"
    log_group      = "${aws_cloudwatch_log_group.ecs-task.name}"
    name           = "${var.name}-${var.environment}-green"
    container_port = 80
    host_port      = "${var.green_port}"
    region         = "${var.region}"
  }
}

resource "aws_ecs_task_definition" "green-task" {
  family                   = "${var.name}-${var.environment}-green"
  container_definitions    = "${data.template_file.green-task-template.rendered}"
  requires_compatibilities = ["EC2"]
  network_mode             = "host"
  cpu                      = "128"
  memory                   = "128"
}
