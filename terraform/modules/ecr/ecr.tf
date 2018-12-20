variable "image_name" {}

resource "aws_ecr_repository" "ecr" {
  name = "${var.image_name}"
}

output "ecr_url" {
  value = "${aws_ecr_repository.ecr.repository_url}"
}
