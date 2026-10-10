
# =============================================================================
# Employee Management - NGINX Ingress Controller Variables
# =============================================================================


# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================

variable "project_name" {
  description = "Name of the application or infrastructure project."
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name must not be empty."
  }
}


# =============================================================================
# ENVIRONMENT CONFIGURATION
# =============================================================================

variable "environment" {
  description = "Deployment environment: dev, staging, or production."
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
      lower(trimspace(var.environment))
    )

    error_message = "environment must be dev, development, staging, stage, prod, or production."
  }
}


# =============================================================================
# KUBERNETES NAMESPACE
# =============================================================================

variable "namespace" {
  description = "Kubernetes namespace where NGINX Ingress Controller is deployed."
  type        = string
  default     = "ingress-nginx"

  validation {
    condition     = length(trimspace(var.namespace)) > 0
    error_message = "namespace must not be empty."
  }
}


# =============================================================================
# HELM RELEASE
# =============================================================================

variable "release_name" {
  description = "Name of the NGINX Ingress Controller Helm release."
  type        = string
  default     = "nginx-ingress"

  validation {
    condition     = length(trimspace(var.release_name)) > 0
    error_message = "release_name must not be empty."
  }
}


# =============================================================================
# HELM OPERATION SETTINGS
# =============================================================================

variable "helm_timeout" {
  description = "Maximum number of seconds Terraform waits for Helm resources to become ready."
  type        = number
  default     = 600

  validation {
    condition     = var.helm_timeout >= 60
    error_message = "helm_timeout must be at least 60 seconds."
  }
}
