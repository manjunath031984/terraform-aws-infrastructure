# =============================================================================
# Employee Management - Root Terraform Data Sources
# =============================================================================


# =============================================================================
# AWS ACCOUNT / PARTITION
# =============================================================================

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}


# =============================================================================
# AWS REGION
# =============================================================================

data "aws_region" "current" {}


# =============================================================================
# EKS KMS KEY POLICY
# =============================================================================
# This policy allows Amazon EKS to use the customer-managed KMS key for
# Kubernetes Secrets encryption.
#
# The EKS cluster IAM role is granted the required KMS permissions.
# =============================================================================

data "aws_iam_policy_document" "eks_kms_key_policy" {

  # ---------------------------------------------------------------------------
  # AWS ACCOUNT ROOT
  # ---------------------------------------------------------------------------

  statement {
    sid    = "EnableRootAccountPermissions"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]
  }


  # ---------------------------------------------------------------------------
  # EKS CLUSTER ROLE
  # ---------------------------------------------------------------------------

  statement {
    sid    = "AllowEKSClusterRole"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        module.iam.eks_cluster_role_arn
      ]
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo"
    ]

    resources = [
      "*"
    ]
  }
}