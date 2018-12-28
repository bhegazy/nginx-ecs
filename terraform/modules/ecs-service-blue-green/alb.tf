resource "aws_security_group" "alb" {
  name   = "${var.name}-${var.environment}-alb"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}-${var.environment}-alb-sg"
  }
}

resource "aws_security_group_rule" "http-green" {
  type              = "ingress"
  from_port         = "${var.green_port}"
  to_port           = "${var.green_port}"
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "http-blue" {
  type              = "ingress"
  from_port         = "${var.blue_port}"
  to_port           = "${var.blue_port}"
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_alb" "alb" {
  name            = "${var.name}-${var.environment}-alb"
  subnets         = ["${split(",",var.public_subnet_ids)}"]
  security_groups = ["${aws_security_group.alb.id}"]

  tags {
    Name = "${var.name}-alb"
  }
}

resource "aws_alb_target_group" "blue-tg" {
  name     = "${var.name}-${var.environment}-blue-tg"
  port     = "${var.blue_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path     = "/index.html"
    protocol = "HTTP"
  }

  tags {
    Name = "${var.name}-${var.environment}-blue"
  }
}

resource "aws_alb_listener" "blue-listener" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "${var.blue_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.blue-tg.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "green-tg" {
  name     = "${var.name}-${var.environment}-green"
  port     = "${var.green_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path     = "/index.html"
    protocol = "HTTP"
  }

  tags {
    Name = "${var.name}-${var.environment}-green"
  }
}

resource "aws_alb_listener" "green-listener" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "${var.green_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.green-tg.id}"
    type             = "forward"
  }
}
