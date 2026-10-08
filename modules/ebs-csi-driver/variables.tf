# =============================================================================
# Employee Management - EBS CSI Driver Module Variables
# =============================================================================


# =============================================================================
# PROJECT
# =============================================================================

variable "project_name" {
  description = "Name of the application or infrastructure project."
  type        = string

  validation {
    condition = (
      length(trimspace(var.project_name)) > 0
    )

    error_message = "project_name must not be empty."
  }
}


# =============================================================================
# ENVIRONMENT
# =============================================================================

variable "environment" {
  description = "Deployment environment such as dev, staging, or prod."
  type        = string

  validation {
    condition = contains(
      [
        "dev",
        "development",
        "staging",
        "stage",
        "prod",
        "production"
      ],
      lower(var.environment)
    )

    error_message = "environment must be dev, development, staging, stage, prod, or production."
  }
}


# =============================================================================
# EKS CLUSTER
# =============================================================================

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string

  validation {
    condition = (
      length(trimspace(var.cluster_name)) > 0
    )

    error_message = "cluster_name must not be empty."
  }
}


# =============================================================================
# OIDC PROVIDER ARN
# =============================================================================

variable "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider associated with the EKS cluster."
  type        = string

  validation {
    condition = (
      length(trimspace(var.oidc_provider_arn)) > 0
    )

    error_message = "oidc_provider_arn must not be empty."
  }
}


# =============================================================================
# OIDC ISSUER HOST/PATH
# =============================================================================

variable "oidc_issuer_hostpath" {
  description = "EKS OIDC issuer host and path without the https:// prefix."
  type        = string

  validation {
    condition = (
      length(trimspace(var.oidc_issuer_hostpath)) > 0 &&
      !startswith(var.oidc_issuer_hostpath, "https://")
    )

    error_message = "oidc_issuer_hostpath must contain the OIDC host/path without https://."
  }
}


# =============================================================================
# AWS PARTITION
# =============================================================================

variable "aws_partition" {
  description = "AWS partition used to construct the EBS CSI Driver managed policy ARN."
  type        = string
  default     = "aws"

  validation {
    condition = contains(
      [
        "aws",
        "aws-us-gov",
        "aws-cn"
      ],
      var.aws_partition
    )

    error_message = "aws_partition must be aws, aws-us-gov, or aws-cn."
  }
}


# =============================================================================
# EBS CSI ADD-ON VERSION
# =============================================================================

variable "addon_version" {
  description = "Version of the Amazon EBS CSI Driver EKS add-on. Null allows EKS to select the compatible version."
  type        = string
  default     = null

  nullable = true
}


# =============================================================================
# COMMON TAGS
# =============================================================================

variable "common_tags" {
  description = "Common tags applied to all taggable EBS CSI Driver resources."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.common_tags :
      length(trimspace(key)) > 0 &&
      length(trimspace(value)) > 0
    ])

    error_message = "All common tag keys and values must be non-empty."
  }
}