# =============================================================================
# Employee Management - KMS Module Outputs
# =============================================================================


# =============================================================================
# KMS KEY
# =============================================================================

output "key_id" {
  description = "ID of the customer-managed KMS key."

  value = aws_kms_key.eks.key_id
}


output "key_arn" {
  description = "ARN of the customer-managed KMS key."

  value = aws_kms_key.eks.arn
}


output "key_alias" {
  description = "Alias of the customer-managed KMS key."

  value = aws_kms_alias.eks.name
}


output "key_alias_arn" {
  description = "ARN of the customer-managed KMS key alias."

  value = aws_kms_alias.eks.arn
}