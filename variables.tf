# ============================================================
# Project / Environment
# ============================================================

variable "project_name" {
  description = "Name of the project"
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, qa, stage, prod."
  }
}


# ============================================================
# AWS Region
# ============================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "aws_region must not be empty."
  }
}


# ============================================================
# VPC
# ============================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by the environment"
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly 2 availability zones must be provided."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly 2 public subnet CIDRs must be provided."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)

  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Exactly 2 private subnet CIDRs must be provided."
  }
}

variable "enable_nat_gateway" {
  description = "Whether NAT gateways should be created"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway"
  type        = bool
  default     = false
}


# ============================================================
# Application
# ============================================================

variable "application_port" {
  description = "Port on which the Employee Management application listens"
  type        = number
  default     = 8080

  validation {
    condition     = var.application_port > 0 && var.application_port <= 65535
    error_message = "application_port must be between 1 and 65535."
  }
}


# ============================================================
# EKS Cluster
# ============================================================

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.37"
}

variable "eks_service_ipv4_cidr" {
  description = "Kubernetes service IPv4 CIDR"
  type        = string
  default     = "172.20.0.0/16"
}

variable "eks_endpoint_private_access" {
  description = "Enable private API endpoint access for EKS"
  type        = bool
  default     = true
}

variable "eks_endpoint_public_access" {
  description = "Enable public API endpoint access for EKS"
  type        = bool
  default     = false
}

variable "eks_public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS API endpoint"
  type        = list(string)
  default     = []
}

variable "eks_enabled_cluster_log_types" {
  description = "EKS control plane log types to enable"
  type        = list(string)

  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  validation {
    condition = alltrue([
      for log_type in var.eks_enabled_cluster_log_types :
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

    error_message = "Invalid EKS cluster log type specified."
  }
}


# ============================================================
# KMS
# ============================================================

variable "kms_deletion_window_in_days" {
  description = "Number of days before the KMS key can be permanently deleted"
  type        = number
  default     = 30

  validation {
    condition = (
      var.kms_deletion_window_in_days >= 7 &&
      var.kms_deletion_window_in_days <= 30
    )

    error_message = "kms_deletion_window_in_days must be between 7 and 30."
  }
}


# ============================================================
# PostgreSQL Node Group
# ============================================================

variable "postgres_desired_size" {
  description = "Desired number of PostgreSQL worker nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.postgres_desired_size >= 1
    error_message = "postgres_desired_size must be at least 1."
  }
}

variable "postgres_min_size" {
  description = "Minimum number of PostgreSQL worker nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.postgres_min_size >= 1
    error_message = "postgres_min_size must be at least 1."
  }
}

variable "postgres_max_size" {
  description = "Maximum number of PostgreSQL worker nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.postgres_max_size >= var.postgres_min_size
    error_message = "postgres_max_size must be greater than or equal to postgres_min_size."
  }
}

variable "postgres_instance_types" {
  description = "EC2 instance types for the PostgreSQL node group"
  type        = list(string)

  default = [
    "t3.medium"
  ]

  validation {
    condition     = length(var.postgres_instance_types) > 0
    error_message = "At least one PostgreSQL instance type must be specified."
  }
}

variable "postgres_capacity_type" {
  description = "Capacity type for PostgreSQL node group"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.postgres_capacity_type)
    error_message = "postgres_capacity_type must be ON_DEMAND or SPOT."
  }
}

# IMPORTANT:
# This name matches modules/node-groups/variables.tf
variable "postgres_disk_size" {
  description = "Root EBS volume size in GB for PostgreSQL worker nodes"
  type        = number
  default     = 30

  validation {
    condition     = var.postgres_disk_size >= 20
    error_message = "postgres_disk_size must be at least 20 GB."
  }
}

variable "postgres_ami_type" {
  description = "AMI type for PostgreSQL EKS worker nodes"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}


# ============================================================
# Application Node Group
# ============================================================

variable "application_desired_size" {
  description = "Desired number of application worker nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.application_desired_size >= 1
    error_message = "application_desired_size must be at least 1."
  }
}

variable "application_min_size" {
  description = "Minimum number of application worker nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.application_min_size >= 1
    error_message = "application_min_size must be at least 1."
  }
}

variable "application_max_size" {
  description = "Maximum number of application worker nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.application_max_size >= var.application_min_size
    error_message = "application_max_size must be greater than or equal to application_min_size."
  }
}

variable "application_instance_types" {
  description = "EC2 instance types for the Employee Management application node group"
  type        = list(string)

  default = [
    "t3.medium"
  ]

  validation {
    condition     = length(var.application_instance_types) > 0
    error_message = "At least one application instance type must be specified."
  }
}

variable "application_capacity_type" {
  description = "Capacity type for application node group"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.application_capacity_type)
    error_message = "application_capacity_type must be ON_DEMAND or SPOT."
  }
}

# IMPORTANT:
# This name matches modules/node-groups/variables.tf
variable "application_disk_size" {
  description = "Root EBS volume size in GB for application worker nodes"
  type        = number
  default     = 30

  validation {
    condition     = var.application_disk_size >= 20
    error_message = "application_disk_size must be at least 20 GB."
  }
}

variable "application_ami_type" {
  description = "AMI type for Employee Management application worker nodes"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}


# ============================================================
# EKS Add-ons
# ============================================================

variable "vpc_cni_version" {
  description = "Version of the Amazon VPC CNI EKS add-on"
  type        = string
  default     = null
  nullable    = true
}

variable "coredns_version" {
  description = "Version of the CoreDNS EKS add-on"
  type        = string
  default     = null
  nullable    = true
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy EKS add-on"
  type        = string
  default     = null
  nullable    = true
}


# ============================================================
# EBS CSI Driver
# ============================================================

variable "ebs_csi_addon_version" {
  description = "Version of the Amazon EBS CSI Driver EKS add-on"
  type        = string
  default     = null
  nullable    = true
}


# ============================================================
# NGINX Ingress Controller
# ============================================================

variable "nginx_namespace" {
  description = "Kubernetes namespace for NGINX Ingress Controller"
  type        = string
  default     = "ingress-nginx"
}

variable "nginx_release_name" {
  description = "Helm release name for NGINX Ingress Controller"
  type        = string
  default     = "nginx-ingress"
}

variable "nginx_helm_repository" {
  description = "Helm repository URL for NGINX Ingress Controller"
  type        = string
  default     = "https://kubernetes.github.io/ingress-nginx"
}

variable "nginx_helm_chart" {
  description = "Helm chart name for NGINX Ingress Controller"
  type        = string
  default     = "ingress-nginx"
}

variable "nginx_chart_version" {
  description = "NGINX Ingress Controller Helm chart version"
  type        = string
  default     = "4.13.0"
}

variable "nginx_helm_timeout" {
  description = "Helm installation timeout in seconds"
  type        = number
  default     = 600

  validation {
    condition     = var.nginx_helm_timeout >= 300
    error_message = "nginx_helm_timeout must be at least 300 seconds."
  }
}

variable "nginx_ingress_class_name" {
  description = "Kubernetes ingress class name used by NGINX"
  type        = string
  default     = "nginx"
}

variable "nginx_ingress_class_default" {
  description = "Whether the NGINX ingress class should be the default ingress class"
  type        = bool
  default     = true
}

variable "nginx_load_balancer_scheme" {
  description = "AWS load balancer scheme for NGINX"
  type        = string
  default     = "internet-facing"

  validation {
    condition = contains(
      ["internet-facing", "internal"],
      var.nginx_load_balancer_scheme
    )

    error_message = "nginx_load_balancer_scheme must be internet-facing or internal."
  }
}

variable "nginx_external_traffic_policy" {
  description = "External traffic policy for NGINX service"
  type        = string
  default     = "Cluster"

  validation {
    condition = contains(
      ["Cluster", "Local"],
      var.nginx_external_traffic_policy
    )

    error_message = "nginx_external_traffic_policy must be Cluster or Local."
  }
}

variable "nginx_replica_count" {
  description = "Number of NGINX Ingress Controller replicas"
  type        = number
  default     = 1

  validation {
    condition     = var.nginx_replica_count >= 1
    error_message = "nginx_replica_count must be at least 1."
  }
}

variable "nginx_cpu_request" {
  description = "CPU request for NGINX Ingress Controller"
  type        = string
  default     = "100m"
}

variable "nginx_memory_request" {
  description = "Memory request for NGINX Ingress Controller"
  type        = string
  default     = "128Mi"
}

variable "nginx_cpu_limit" {
  description = "CPU limit for NGINX Ingress Controller"
  type        = string
  default     = "500m"
}

variable "nginx_memory_limit" {
  description = "Memory limit for NGINX Ingress Controller"
  type        = string
  default     = "512Mi"
}