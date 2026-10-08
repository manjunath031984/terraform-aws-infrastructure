# =============================================================================
# Employee Management - KMS Module
# =============================================================================
# Creates a customer-managed AWS KMS key for:
#
# - Amazon EKS Kubernetes Secrets encryption
#
# The key is intentionally managed separately from the EKS module.
#
# All taggable AWS resources use meaningful and consistent tags.
# =============================================================================


# =============================================================================
# KMS KEY
# =============================================================================

resource "aws_kms_key" "eks" {
  description = "Customer-managed KMS key for encrypting Employee Management EKS Kubernetes Secrets."

  enable_key_rotation = true

  deletion_window_in_days = var.deletion_window_in_days

  policy = var.key_policy

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-eks-kms-key"
      Module    = "KMS"
      Component = "EKS"
      Resource  = "KMS Key"
      Purpose   = "Encrypt Kubernetes Secrets stored by Amazon EKS"
      Role      = "EKS Secrets Encryption"
      Service   = "Amazon EKS"
    }
  )
}


# =============================================================================
# KMS ALIAS
# =============================================================================

resource "aws_kms_alias" "eks" {
  name = "alias/${var.project_name}-eks"

  target_key_id = aws_kms_key.eks.key_id
}