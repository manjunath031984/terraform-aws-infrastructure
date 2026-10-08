# =============================================================================
# Employee Management - EKS Add-ons Module Variables
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
# VPC CNI VERSION
# =============================================================================

variable "vpc_cni_version" {
  description = "Version of the Amazon VPC CNI EKS add-on."
  type        = string
  default     = null

  nullable = true
}


# =============================================================================
# COREDNS VERSION
# =============================================================================

variable "coredns_version" {
  description = "Version of the CoreDNS EKS add-on."
  type        = string
  default     = null

  nullable = true
}


# =============================================================================
# KUBE-PROXY VERSION
# =============================================================================

variable "kube_proxy_version" {
  description = "Version of the kube-proxy EKS add-on."
  type        = string
  default     = null

  nullable = true
}


# =============================================================================
# COMMON TAGS
# =============================================================================

variable "common_tags" {
  description = "Common tags applied to all taggable EKS add-ons."
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