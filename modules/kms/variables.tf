# =============================================================================
# Employee Management - KMS Module Variables
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
# KMS DELETION WINDOW
# =============================================================================

variable "deletion_window_in_days" {
  description = "Number of days before a scheduled KMS key deletion takes effect."
  type        = number
  default     = 30

  validation {
    condition = (
      var.deletion_window_in_days >= 7 &&
      var.deletion_window_in_days <= 30
    )

    error_message = "deletion_window_in_days must be between 7 and 30 days."
  }
}


# =============================================================================
# KMS KEY POLICY
# =============================================================================

variable "key_policy" {
  description = "IAM policy JSON document defining permissions for the KMS key."
  type        = string

  validation {
    condition = (
      length(trimspace(var.key_policy)) > 0
    )

    error_message = "key_policy must not be empty."
  }
}


# =============================================================================
# COMMON TAGS
# =============================================================================

variable "common_tags" {
  description = "Common tags applied to all taggable KMS resources."
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