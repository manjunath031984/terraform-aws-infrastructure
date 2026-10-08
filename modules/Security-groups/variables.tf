variable "security_group_name" {
  description = "Name of the Jenkins security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
}

variable "jenkins_allowed_cidr" {
  description = "CIDR blocks allowed for Jenkins access"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the security group"
  type        = map(string)
}