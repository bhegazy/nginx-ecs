resource "aws_security_group" "ecs" {
  name        = "${var.name}-sg"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for ECS"

  tags {
    Name = "${var.name}-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ecs-ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.ecs.id}"
}

resource "aws_security_group_rule" "ecs-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ecs.id}"
}

resource "aws_launch_configuration" "ecs" {
  name_prefix          = "${var.name}-lc"
  image_id             = "${var.ami}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
  key_name             = "${var.key_name}"
  security_groups      = ["${aws_security_group.ecs.id}"]
  user_data            = "${data.template_file.user-data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  name                 = "${var.name}-asg"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  launch_configuration = "${aws_launch_configuration.ecs.id}"
  vpc_zone_identifier  = ["${split(",",var.private_subnet_ids)}"]

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_cluster" "ecs" {
  name = "${var.name}"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user-data" {
  template = "${file("${path.module}/templates/user_data.sh")}"

  vars {
    cluster_name = "${var.name}"
  }
}
