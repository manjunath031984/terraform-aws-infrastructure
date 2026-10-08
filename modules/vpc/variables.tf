# =============================================================================
# Employee Management - VPC Module Variables
# =============================================================================

variable "project_name" {
  description = "Name of the application or project."
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
      ["dev", "development", "staging", "stage", "prod", "production"],
      lower(var.environment)
    )

    error_message = "environment must be dev, development, staging, stage, prod, or production."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the Employee Management VPC."
  type        = string

  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet configuration by subnet key."

  type = map(object({
    cidr              = string
    availability_zone = string
    name              = string
  }))

  validation {
    condition     = length(var.public_subnets) == 2
    error_message = "Exactly two public subnets are required for the two-AZ architecture."
  }
}

variable "private_subnets" {
  description = "Private subnet configuration by subnet key."

  type = map(object({
    cidr              = string
    availability_zone = string
    name              = string
    nat_gateway_key   = string
  }))

  validation {
    condition     = length(var.private_subnets) == 2
    error_message = "Exactly two private subnets are required for the two-AZ architecture."
  }
}

variable "common_tags" {
  description = "Common tags applied to every VPC resource."
  type        = map(string)

  default = {}

  validation {
    condition = alltrue([
      for key, value in var.common_tags :
      length(trimspace(key)) > 0 && length(trimspace(value)) > 0
    ])

    error_message = "All common tag keys and values must be non-empty."
  }

}