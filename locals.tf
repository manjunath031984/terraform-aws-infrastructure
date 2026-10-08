# =============================================================================
# Employee Management - Root Terraform Locals
# =============================================================================

locals {

  # ---------------------------------------------------------------------------
  # COMMON TAGS
  # ---------------------------------------------------------------------------

  common_tags = {
    Project     = "Employee-Management"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "CloudOps"
    Application = "Employee-Management"
    CostCenter  = "Employee-Management"
  }


  # ---------------------------------------------------------------------------
  # EKS OIDC ISSUER HOST/PATH
  # ---------------------------------------------------------------------------
  # Converts:
  #
  # https://oidc.eks.us-east-1.amazonaws.com/id/XXXXXXXX
  #
  # to:
  #
  # oidc.eks.us-east-1.amazonaws.com/id/XXXXXXXX
  #
  # Required by the EBS CSI IAM trust policy.
  # ---------------------------------------------------------------------------

  eks_oidc_issuer_hostpath = replace(
    module.eks.oidc_issuer_url,
    "https://",
    ""
  )
}