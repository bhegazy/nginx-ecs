resource "aws_security_group" "alb" {
  name   = "${var.name}-${var.environment}-alb"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}-${var.environment}-alb-sg"
  }
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
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

resource "aws_alb_target_group" "default" {
  name     = "${var.name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path     = "/index.html"
    protocol = "HTTP"
  }

  tags {
    Name = "${var.name}-${var.environment}-alb-tg"
  }
}

resource "aws_alb" "alb" {
  name            = "${var.name}-${var.environment}-alb"
  subnets         = ["${split(",",var.public_subnet_ids)}"]
  security_groups = ["${aws_security_group.alb.id}"]

  tags {
    Name = "${var.name}-alb"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default.id}"
    type             = "forward"
  }
}
