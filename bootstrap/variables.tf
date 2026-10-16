
variable "aws_region" {
  description = "AWS region for the Terraform state bucket"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "employee-management"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string
  default     = "employee-management-terraform-state"
}

variable "dynamodb_lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "employee-management-terraform-locks"
}
