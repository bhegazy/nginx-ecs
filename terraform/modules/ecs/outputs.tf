output "ecs_cluster_arn" {
  value = "${aws_ecs_cluster.ecs.arn}"
}

output "ecs_iam_role" {
  value = "${aws_iam_role.ecs.arn}"
}
