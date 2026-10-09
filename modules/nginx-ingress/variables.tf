# =============================================================================
# Employee Management - NGINX Ingress Controller Variables
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
# KUBERNETES NAMESPACE
# =============================================================================

variable "namespace" {
  description = "Kubernetes namespace where NGINX Ingress Controller will be deployed."
  type        = string
  default     = "ingress-nginx"

  validation {
    condition = (
      length(trimspace(var.namespace)) > 0
    )

    error_message = "namespace must not be empty."
  }
}


# =============================================================================
# HELM RELEASE
# =============================================================================


variable "release_name" {
  description = "Helm release name for the NGINX Ingress Controller."
  type        = string
  default     = "nginx-ingress"

  validation {
    condition     = length(trimspace(var.release_name)) > 0
    error_message = "release_name must not be empty."
  }
}

variable "helm_repository" {
  description = "Helm repository containing the NGINX Ingress Controller chart."
  type        = string
  default     = "https://kubernetes.github.io/ingress-nginx"
}

variable "helm_chart" {
  description = "Helm chart name for the NGINX Ingress Controller."
  type        = string
  default     = "ingress-nginx"
}

variable "chart_version" {
  description = "Version of the NGINX Ingress Controller Helm chart."
  type        = string
  default     = "4.13.0"
}

variable "helm_timeout" {
  description = "Maximum time Terraform waits for the NGINX Ingress Helm release."
  type        = number
  default     = 600

  validation {
    condition     = var.helm_timeout >= 60
    error_message = "helm_timeout must be at least 60 seconds."
  }
}



# =============================================================================
# INGRESS CLASS
# =============================================================================

variable "ingress_class_name" {
  description = "Kubernetes IngressClass name used by NGINX."
  type        = string
  default     = "nginx"

  validation {
    condition = (
      length(trimspace(var.ingress_class_name)) > 0
    )

    error_message = "ingress_class_name must not be empty."
  }
}


variable "ingress_class_default" {
  description = "Whether the NGINX IngressClass should be the default IngressClass."
  type        = bool
  default     = true
}


# =============================================================================
# AWS LOAD BALANCER
# =============================================================================

variable "load_balancer_scheme" {
  description = "AWS Network Load Balancer scheme."
  type        = string
  default     = "internet-facing"

  validation {
    condition = contains(
      [
        "internet-facing",
        "internal"
      ],
      var.load_balancer_scheme
    )

    error_message = "load_balancer_scheme must be internet-facing or internal."
  }
}


variable "external_traffic_policy" {
  description = "Kubernetes Service external traffic policy."
  type        = string
  default     = "Cluster"

  validation {
    condition = contains(
      [
        "Cluster",
        "Local"
      ],
      var.external_traffic_policy
    )

    error_message = "external_traffic_policy must be Cluster or Local."
  }
}


# =============================================================================
# NGINX RESOURCES
# =============================================================================

variable "replica_count" {
  description = "Number of NGINX Ingress Controller replicas."
  type        = number
  default     = 1

  validation {
    condition = (
      var.replica_count >= 1
    )

    error_message = "replica_count must be at least 1."
  }
}


variable "cpu_request" {
  description = "CPU request for the NGINX Ingress Controller."
  type        = string
  default     = "100m"

  validation {
    condition = (
      length(trimspace(var.cpu_request)) > 0
    )

    error_message = "cpu_request must not be empty."
  }
}


variable "memory_request" {
  description = "Memory request for the NGINX Ingress Controller."
  type        = string
  default     = "128Mi"

  validation {
    condition = (
      length(trimspace(var.memory_request)) > 0
    )

    error_message = "memory_request must not be empty."
  }
}


variable "cpu_limit" {
  description = "CPU limit for the NGINX Ingress Controller."
  type        = string
  default     = "500m"

  validation {
    condition = (
      length(trimspace(var.cpu_limit)) > 0
    )

    error_message = "cpu_limit must not be empty."
  }
}


variable "memory_limit" {
  description = "Memory limit for the NGINX Ingress Controller."
  type        = string
  default     = "512Mi"

  validation {
    condition = (
      length(trimspace(var.memory_limit)) > 0
    )

    error_message = "memory_limit must not be empty."
  }
}