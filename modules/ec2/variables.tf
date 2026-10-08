variable "ami_id" {
  description = "AMI ID used to launch the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to the EC2 instance"
  type        = list(string)
}

variable "tags" {
  description = "EC2 resource tags"
  type        = map(string)
}