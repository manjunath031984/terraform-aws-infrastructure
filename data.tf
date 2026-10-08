data "aws_key_pair" "jenkins" {
  key_name = var.key_pair_name
}

data "aws_vpc" "default" {
  default = true
}