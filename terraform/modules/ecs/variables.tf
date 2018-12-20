variable "name" {}

variable "vpc_id" {}
variable "vpc_cidr" {}
variable "private_subnet_ids" {}
variable "public_subnet_ids" {}
variable "key_name" {}
variable "ami" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "max_size" {
  default = 3
}

variable "min_size" {
  default = 2
}
