# =============================================================================
# Employee Management - Development Environment
# Terraform Variables
# =============================================================================


# =============================================================================
# AWS
# =============================================================================

aws_region = "us-east-1"


# =============================================================================
# PROJECT
# =============================================================================

project_name = "Employee-Management"

environment = "dev"


# =============================================================================
# VPC
# =============================================================================

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

enable_nat_gateway = true

# One NAT Gateway per Availability Zone.
# This provides better AZ isolation than a single NAT Gateway.
single_nat_gateway = false


# =============================================================================
# SECURITY GROUPS
# =============================================================================

application_port = 8080


# =============================================================================
# EKS
# =============================================================================

kubernetes_version = "1.36"

eks_service_ipv4_cidr = "172.20.0.0/16"

# Keep the Kubernetes API private.
eks_endpoint_private_access = true

# Public API endpoint disabled.
eks_endpoint_public_access = false

eks_public_access_cidrs = []

eks_enabled_cluster_log_types = [
  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"
]


# =============================================================================
# KMS
# =============================================================================

kms_deletion_window_in_days = 7


# =============================================================================
# POSTGRESQL EKS NODE GROUP
# =============================================================================

postgres_desired_size = 1

postgres_min_size = 1

postgres_max_size = 1

postgres_instance_types = [
  "t3.medium"
]

postgres_capacity_type = "ON_DEMAND"

# Must match modules/node-groups/variables.tf
postgres_disk_size = 20

postgres_ami_type = "AL2023_x86_64_STANDARD"


# =============================================================================
# EMPLOYEE MANAGEMENT APPLICATION EKS NODE GROUP
# =============================================================================

application_desired_size = 1

application_min_size = 1

application_max_size = 1

application_instance_types = [
  "t3.medium"
]

application_capacity_type = "ON_DEMAND"

# Must match modules/node-groups/variables.tf
application_disk_size = 30

application_ami_type = "AL2023_x86_64_STANDARD"


# =============================================================================
# EKS ADD-ONS
# =============================================================================

# Leave versions as null so the EKS module can use compatible versions.

vpc_cni_version = null

coredns_version = null

kube_proxy_version = null


# =============================================================================
# EBS CSI DRIVER
# =============================================================================

ebs_csi_addon_version = null


# =============================================================================
# NGINX INGRESS CONTROLLER
# =============================================================================

nginx_namespace = "ingress-nginx"

nginx_release_name = "nginx-ingress"

nginx_helm_repository = "https://kubernetes.github.io/ingress-nginx"

nginx_helm_chart = "ingress-nginx"

nginx_chart_version = "4.13.0"

nginx_helm_timeout = 600


# =============================================================================
# NGINX INGRESS CLASS
# =============================================================================

nginx_ingress_class_name = "nginx"

nginx_ingress_class_default = true


# =============================================================================
# NGINX AWS NETWORK LOAD BALANCER
# =============================================================================

nginx_load_balancer_scheme = "internet-facing"

nginx_external_traffic_policy = "Cluster"


# =============================================================================
# NGINX RESOURCE CONFIGURATION
# =============================================================================

nginx_replica_count = 1

nginx_cpu_request = "100m"

nginx_memory_request = "128Mi"

nginx_cpu_limit = "500m"

nginx_memory_limit = "512Mi"