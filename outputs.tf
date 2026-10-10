
# =============================================================================
# Employee Management - Root Terraform Outputs
# =============================================================================


# =============================================================================
# VPC OUTPUTS
# =============================================================================

output "vpc_id" {
  description = "ID of the Employee Management VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.vpc.private_subnet_ids
}


# =============================================================================
# EKS CLUSTER OUTPUTS
# =============================================================================

output "eks_cluster_name" {
  description = "Name of the Employee Management EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS Kubernetes API server."
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "eks_cluster_arn" {
  description = "ARN of the Employee Management EKS cluster."
  value       = module.eks.cluster_arn
}


# =============================================================================
# EKS NODE GROUP OUTPUTS
# =============================================================================

output "postgres_node_group_name" {
  description = "Name of the PostgreSQL EKS managed node group."
  value       = module.node_groups.postgres_node_group_name
}

output "postgres_node_group_status" {
  description = "Status of the PostgreSQL EKS managed node group."
  value       = module.node_groups.postgres_node_group_status
}

output "application_node_group_name" {
  description = "Name of the Employee Management application EKS managed node group."
  value       = module.node_groups.application_node_group_name
}

output "application_node_group_status" {
  description = "Status of the Employee Management application EKS managed node group."
  value       = module.node_groups.application_node_group_status
}


# =============================================================================
# EKS IAM OIDC PROVIDER OUTPUT
# =============================================================================

output "eks_oidc_provider_arn" {
  description = "ARN of the EKS IAM OIDC identity provider."
  value       = aws_iam_openid_connect_provider.eks.arn
}


# =============================================================================
# EBS CSI DRIVER OUTPUTS
# =============================================================================

# Add EBS CSI outputs here only if the corresponding outputs are
# declared in modules/ebs-csi-driver/outputs.tf.


# =============================================================================
# NGINX INGRESS CONTROLLER OUTPUTS
# =============================================================================

output "nginx_namespace" {
  description = "Kubernetes namespace where NGINX Ingress Controller is deployed."
  value       = module.nginx_ingress.namespace
}

output "nginx_release_name" {
  description = "Name of the NGINX Ingress Controller Helm release."
  value       = module.nginx_ingress.release_name
}

output "nginx_release_status" {
  description = "Current status of the NGINX Ingress Controller Helm release."
  value       = module.nginx_ingress.release_status
}

output "nginx_chart_version" {
  description = "Version of the local NGINX wrapper Helm chart."
  value       = module.nginx_ingress.chart_version
}

output "nginx_chart_path" {
  description = "Local filesystem path of the NGINX wrapper Helm chart."
  value       = module.nginx_ingress.chart_path
}

# The local wrapper chart currently does not export ingress_class_name.
# The value is maintained in charts/nginx-ingress/values.yaml.
# Keep this output only if you want the known configured class name.
output "nginx_ingress_class_name" {
  description = "Configured Kubernetes IngressClass name for NGINX."
  value       = "nginx"
}
