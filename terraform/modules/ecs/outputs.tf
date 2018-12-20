output "ecs_cluster_arn" {
  value = "${aws_ecs_cluster.ecs.arn}"
}

output "ecs_iam_role" {
  value = "${aws_iam_role.ecs.arn}"
}

output "ecs_alb_tg_arn" {
  value = "${aws_alb_target_group.default.arn}"
}
