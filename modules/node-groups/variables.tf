# =============================================================================
# Employee Management - EKS Node Groups Module Variables
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
# EKS NODE IAM ROLE
# =============================================================================

variable "node_role_arn" {
  description = "ARN of the IAM role assigned to EKS managed worker nodes."
  type        = string

  validation {
    condition = (
      length(trimspace(var.node_role_arn)) > 0
    )

    error_message = "node_role_arn must not be empty."
  }
}


# =============================================================================
# NODE ROLE DEPENDENCY
# =============================================================================
# This is used only to ensure that the IAM role policy attachments are
# completed before EKS managed node groups are created.
# =============================================================================


# =============================================================================
# PRIVATE SUBNETS
# =============================================================================

variable "private_subnet_ids" {
  description = "Private subnet IDs where EKS worker nodes will be deployed."
  type        = list(string)

  validation {
    condition = (
      length(var.private_subnet_ids) >= 2 &&
      length(distinct(var.private_subnet_ids)) == length(var.private_subnet_ids)
    )

    error_message = "At least two unique private subnet IDs are required for the EKS node groups."
  }
}


# =============================================================================
# POSTGRESQL NODE GROUP - SCALING
# =============================================================================

variable "postgres_desired_size" {
  description = "Desired number of PostgreSQL worker nodes."
  type        = number
  default     = 1

  validation {
    condition = (
      var.postgres_desired_size >= 1
    )

    error_message = "postgres_desired_size must be at least 1."
  }
}


variable "postgres_min_size" {
  description = "Minimum number of PostgreSQL worker nodes."
  type        = number
  default     = 1

  validation {
    condition = (
      var.postgres_min_size >= 1
    )

    error_message = "postgres_min_size must be at least 1."
  }
}


variable "postgres_max_size" {
  description = "Maximum number of PostgreSQL worker nodes."
  type        = number
  default     = 1

  validation {
    condition = (
      var.postgres_max_size >= var.postgres_min_size
    )

    error_message = "postgres_max_size must be greater than or equal to postgres_min_size."
  }
}


# =============================================================================
# POSTGRESQL NODE GROUP - INSTANCE
# =============================================================================

variable "postgres_instance_types" {
  description = "EC2 instance types used by the PostgreSQL node group."
  type        = list(string)
  default     = ["t3.medium"]

  validation {
    condition = (
      length(var.postgres_instance_types) > 0
    )

    error_message = "At least one PostgreSQL instance type must be specified."
  }
}


variable "postgres_capacity_type" {
  description = "Capacity type for the PostgreSQL node group."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition = contains(
      [
        "ON_DEMAND",
        "SPOT"
      ],
      var.postgres_capacity_type
    )

    error_message = "postgres_capacity_type must be ON_DEMAND or SPOT."
  }
}


variable "postgres_disk_size" {
  description = "Root EBS volume size in GiB for PostgreSQL worker nodes."
  type        = number
  default     = 30

  validation {
    condition = (
      var.postgres_disk_size >= 20
    )

    error_message = "postgres_disk_size must be at least 20 GiB."
  }
}


variable "postgres_ami_type" {
  description = "AMI type used by the PostgreSQL EKS managed node group."
  type        = string
  default     = "AL2023_x86_64_STANDARD"

  validation {
    condition = contains(
      [
        "AL2023_x86_64_STANDARD",
        "AL2023_ARM_64_STANDARD",
        "AL2_x86_64"
      ],
      var.postgres_ami_type
    )

    error_message = "Unsupported PostgreSQL EKS AMI type."
  }
}


# =============================================================================
# APPLICATION NODE GROUP - SCALING
# =============================================================================

variable "application_desired_size" {
  description = "Desired number of Employee Management application worker nodes."
  type        = number
  default     = 1

  validation {
    condition = (
      var.application_desired_size >= 1
    )

    error_message = "application_desired_size must be at least 1."
  }
}


variable "application_min_size" {
  description = "Minimum number of Employee Management application worker nodes."
  type        = number
  default     = 1

  validation {
    condition = (
      var.application_min_size >= 1
    )

    error_message = "application_min_size must be at least 1."
  }
}


variable "application_max_size" {
  description = "Maximum number of Employee Management application worker nodes."
  type        = number
  default     = 1

  validation {
    condition = (
      var.application_max_size >= var.application_min_size
    )

    error_message = "application_max_size must be greater than or equal to application_min_size."
  }
}


# =============================================================================
# APPLICATION NODE GROUP - INSTANCE
# =============================================================================

variable "application_instance_types" {
  description = "EC2 instance types used by the Employee Management application node group."
  type        = list(string)
  default     = ["t3.medium"]

  validation {
    condition = (
      length(var.application_instance_types) > 0
    )

    error_message = "At least one application instance type must be specified."
  }
}


variable "application_capacity_type" {
  description = "Capacity type for the Employee Management application node group."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition = contains(
      [
        "ON_DEMAND",
        "SPOT"
      ],
      var.application_capacity_type
    )

    error_message = "application_capacity_type must be ON_DEMAND or SPOT."
  }
}


variable "application_disk_size" {
  description = "Root EBS volume size in GiB for Employee Management application worker nodes."
  type        = number
  default     = 30

  validation {
    condition = (
      var.application_disk_size >= 20
    )

    error_message = "application_disk_size must be at least 20 GiB."
  }
}


variable "application_ami_type" {
  description = "AMI type used by the Employee Management application EKS managed node group."
  type        = string
  default     = "AL2023_x86_64_STANDARD"

  validation {
    condition = contains(
      [
        "AL2023_x86_64_STANDARD",
        "AL2023_ARM_64_STANDARD",
        "AL2_x86_64"
      ],
      var.application_ami_type
    )

    error_message = "Unsupported application EKS AMI type."
  }
}

# =============================================================================
# COMMON TAGS
# =============================================================================

variable "common_tags" {
  description = "Common tags applied to all EKS managed node groups."
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