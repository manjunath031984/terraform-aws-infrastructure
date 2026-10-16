# --------------------------------------------------
# S3 Terraform State Bucket Outputs
# --------------------------------------------------

output "terraform_state_bucket_name" {
  description = "Name of the S3 bucket used to store Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket used to store Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_state_bucket_region" {
  description = "AWS region where the Terraform state bucket is created"
  value       = aws_s3_bucket.terraform_state.region
}

output "terraform_state_bucket_versioning" {
  description = "Versioning status of the Terraform state bucket"
  value       = aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status
}

# --------------------------------------------------
# DynamoDB Terraform State Locking Outputs
# --------------------------------------------------

output "terraform_lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "terraform_lock_table_arn" {
  description = "ARN of the DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "terraform_lock_table_billing_mode" {
  description = "Billing mode of the Terraform lock table"
  value       = aws_dynamodb_table.terraform_locks.billing_mode
}

# --------------------------------------------------
# Bootstrap Configuration Outputs
# --------------------------------------------------

output "aws_region" {
  description = "AWS region where bootstrap resources are created"
  value       = var.aws_region
}

output "project_name" {
  description = "Name of the project associated with the bootstrap resources"
  value       = var.project_name
}