
output "aws_region" {
  description = "AWS deployment region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs for EKS worker nodes"
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Kubernetes API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS Kubernetes version"
  value       = module.eks.cluster_version
}

output "eks_oidc_issuer_url" {
  description = "OIDC issuer URL"
  value       = module.eks.oidc_issuer_url
}

output "postgres_node_group_name" {
  description = "PostgreSQL managed node group"
  value       = module.eks_node_groups.postgres_node_group_name
}

output "employee_node_group_name" {
  description = "Employee Management managed node group"
  value       = module.eks_node_groups.employee_node_group_name
}
