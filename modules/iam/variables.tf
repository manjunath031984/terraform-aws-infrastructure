# =============================================================================
# Employee Management - IAM Module Variables
# =============================================================================


variable "project_name" {
  description = "Name of the application or infrastructure project."
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name must not be empty."
  }
}


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


variable "common_tags" {
  description = "Common tags applied to all taggable IAM resources."
  type        = map(string)

  default = {}

  validation {
    condition = alltrue([
      for key, value in var.common_tags :
      length(trimspace(key)) > 0 &&
      length(trimspace(value)) > 0
    ])

    error_message = "All common tag keys and values must be non-empty."
  }
}