# =============================================================================
# Employee Management - EKS Module Variables
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
# EKS KUBERNETES VERSION
# =============================================================================

variable "kubernetes_version" {
  description = "Kubernetes version used by the Amazon EKS cluster."
  type        = string

  validation {
    condition = can(regex(
      "^[0-9]+\\.[0-9]+$",
      var.kubernetes_version
    ))

    error_message = "kubernetes_version must use the format MAJOR.MINOR, for example 1.33."
  }
}


# =============================================================================
# EKS CLUSTER IAM ROLE
# =============================================================================

variable "cluster_role_arn" {
  description = "ARN of the IAM role used by the Amazon EKS control plane."
  type        = string

  validation {
    condition = (
      length(trimspace(var.cluster_role_arn)) > 0
    )

    error_message = "cluster_role_arn must not be empty."
  }
}


# =============================================================================
# PRIVATE SUBNETS
# =============================================================================

variable "private_subnet_ids" {
  description = "Private subnet IDs where the EKS control-plane network interfaces will be placed."
  type        = list(string)

  validation {
    condition = (
      length(var.private_subnet_ids) >= 2 &&
      length(distinct(var.private_subnet_ids)) == length(var.private_subnet_ids)
    )

    error_message = "At least two unique private subnet IDs are required for the EKS cluster."
  }
}


# =============================================================================
# KUBERNETES SERVICE CIDR
# =============================================================================

variable "service_ipv4_cidr" {
  description = "IPv4 CIDR used by Kubernetes services inside the EKS cluster."
  type        = string
  default     = "172.20.0.0/16"

  validation {
    condition = can(cidrhost(
      var.service_ipv4_cidr,
      0
    ))

    error_message = "service_ipv4_cidr must be a valid IPv4 CIDR."
  }
}


# =============================================================================
# EKS API ENDPOINT - PRIVATE ACCESS
# =============================================================================

variable "endpoint_private_access" {
  description = "Whether the EKS Kubernetes API endpoint should be accessible privately inside the VPC."
  type        = bool
  default     = true
}


# =============================================================================
# EKS API ENDPOINT - PUBLIC ACCESS
# =============================================================================

variable "endpoint_public_access" {
  description = "Whether the EKS Kubernetes API endpoint should be publicly accessible."
  type        = bool
  default     = false
}


# =============================================================================
# EKS PUBLIC API ENDPOINT CIDRS
# =============================================================================

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS Kubernetes API endpoint."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.public_access_cidrs :
      can(cidrhost(cidr, 0))
    ])

    error_message = "Every public_access_cidrs value must be a valid CIDR block."
  }
}


# =============================================================================
# EKS CONTROL-PLANE LOGGING
# =============================================================================

variable "enabled_cluster_log_types" {
  description = "EKS control-plane log types to send to Amazon CloudWatch Logs."
  type        = set(string)

  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  validation {
    condition = alltrue([
      for log_type in var.enabled_cluster_log_types :
      contains(
        [
          "api",
          "audit",
          "authenticator",
          "controllerManager",
          "scheduler"
        ],
        log_type
      )
    ])

    error_message = "Invalid EKS cluster log type. Allowed values are api, audit, authenticator, controllerManager, and scheduler."
  }
}


# =============================================================================
# OPTIONAL KMS KEY
# =============================================================================

variable "kms_key_arn" {
  description = "Optional ARN of the customer-managed KMS key used to encrypt Kubernetes Secrets."
  type        = string
  default     = null

  nullable = true

  validation {
    condition = (
      var.kms_key_arn == null ||
      length(trimspace(var.kms_key_arn)) > 0
    )

    error_message = "kms_key_arn must be null or a non-empty KMS key ARN."
  }
}


# =============================================================================
# COMMON TAGS
# =============================================================================

variable "common_tags" {
  description = "Common tags applied to the EKS cluster."
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