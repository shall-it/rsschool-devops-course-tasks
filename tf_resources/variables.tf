
variable "aws_region" {
  default = "us-east-1"
}

variable "aws_iam_role_name" {
  default = "GithubActionsRole"
}

variable "instance_type" {
  default = "t4g.micro"
}

variable "key_pair" {
  default = "task_2"
}

variable "primary_cidr_block" {
  default = "10.0.0.0/16"
}