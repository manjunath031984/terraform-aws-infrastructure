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

output "vpc_cidr" {
  description = "CIDR block of the Employee Management VPC."
  value       = var.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways."
  value       = module.vpc.nat_gateway_ids
}


# =============================================================================
# SECURITY GROUP OUTPUTS
# =============================================================================

output "eks_node_security_group_id" {
  description = "ID of the EKS worker node security group."
  value       = module.security_groups.eks_node_security_group_id
}

output "postgres_security_group_id" {
  description = "ID of the PostgreSQL security group."
  value       = module.security_groups.postgres_security_group_id
}

output "nginx_ingress_security_group_id" {
  description = "ID of the NGINX Ingress security group."
  value       = module.security_groups.nginx_ingress_security_group_id
}


# =============================================================================
# IAM OUTPUTS
# =============================================================================

output "eks_cluster_role_name" {
  description = "Name of the EKS cluster IAM role."
  value       = module.iam.eks_cluster_role_name
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = module.iam.eks_cluster_role_arn
}

output "eks_node_role_name" {
  description = "Name of the EKS worker node IAM role."
  value       = module.iam.eks_node_role_name
}

output "eks_node_role_arn" {
  description = "ARN of the EKS worker node IAM role."
  value       = module.iam.eks_node_role_arn
}


# =============================================================================
# KMS OUTPUTS
# =============================================================================

output "eks_kms_key_id" {
  description = "ID of the customer-managed KMS key used for EKS Secrets encryption."
  value       = module.kms.key_id
}

output "eks_kms_key_arn" {
  description = "ARN of the customer-managed KMS key used for EKS Secrets encryption."
  value       = module.kms.key_arn
}

output "eks_kms_key_alias" {
  description = "Alias of the customer-managed EKS KMS key."
  value       = module.kms.key_alias
}


# =============================================================================
# EKS CLUSTER OUTPUTS
# =============================================================================

output "eks_cluster_id" {
  description = "ID of the Employee Management EKS cluster."
  value       = module.eks.cluster_id
}

output "eks_cluster_name" {
  description = "Name of the Employee Management EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "ARN of the Employee Management EKS cluster."
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API endpoint of the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_platform_version" {
  description = "EKS platform version."
  value       = module.eks.cluster_platform_version
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster."
  value       = module.eks.cluster_version
}

output "eks_cluster_security_group_id" {
  description = "Cluster security group automatically created by Amazon EKS."
  value       = module.eks.cluster_security_group_id
}

output "eks_oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster."
  value       = module.eks.oidc_issuer_url
}


# =============================================================================
# NODE GROUP OUTPUTS
# =============================================================================

output "postgres_node_group_name" {
  description = "Name of the PostgreSQL EKS managed node group."
  value       = module.node_groups.postgres_node_group_name
}

output "postgres_node_group_arn" {
  description = "ARN of the PostgreSQL EKS managed node group."
  value       = module.node_groups.postgres_node_group_arn
}

output "postgres_node_group_status" {
  description = "Status of the PostgreSQL EKS managed node group."
  value       = module.node_groups.postgres_node_group_status
}

output "application_node_group_name" {
  description = "Name of the Employee Management application EKS managed node group."
  value       = module.node_groups.application_node_group_name
}

output "application_node_group_arn" {
  description = "ARN of the Employee Management application EKS managed node group."
  value       = module.node_groups.application_node_group_arn
}

output "application_node_group_status" {
  description = "Status of the Employee Management application EKS managed node group."
  value       = module.node_groups.application_node_group_status
}


# =============================================================================
# EKS ADD-ON OUTPUTS
# =============================================================================

output "vpc_cni_addon_version" {
  description = "Installed VPC CNI EKS add-on version."
  value       = module.eks_addons.vpc_cni_version
}

output "coredns_addon_version" {
  description = "Installed CoreDNS EKS add-on version."
  value       = module.eks_addons.coredns_version
}

output "kube_proxy_addon_version" {
  description = "Installed kube-proxy EKS add-on version."
  value       = module.eks_addons.kube_proxy_version
}


# =============================================================================
# EBS CSI OUTPUTS
# =============================================================================

output "ebs_csi_role_name" {
  description = "IAM role name used by the AWS EBS CSI Driver."
  value       = module.ebs_csi_driver.role_name
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN used by the AWS EBS CSI Driver."
  value       = module.ebs_csi_driver.role_arn
}

output "ebs_csi_addon_version" {
  description = "Installed AWS EBS CSI Driver EKS add-on version."
  value       = module.ebs_csi_driver.addon_version
}


# =============================================================================
# NGINX INGRESS OUTPUTS
# =============================================================================

output "nginx_ingress_namespace" {
  description = "Kubernetes namespace used by NGINX Ingress."
  value       = module.nginx_ingress.namespace
}

output "nginx_ingress_release_name" {
  description = "Helm release name of the NGINX Ingress Controller."
  value       = module.nginx_ingress.release_name
}

output "nginx_ingress_release_status" {
  description = "Current status of the NGINX Ingress Helm release."
  value       = module.nginx_ingress.release_status
}

output "nginx_ingress_chart_version" {
  description = "Installed NGINX Ingress Helm chart version."
  value       = module.nginx_ingress.chart_version
}

output "nginx_ingress_class_name" {
  description = "Kubernetes IngressClass name used by NGINX."
  value       = module.nginx_ingress.ingress_class_name
}


# =============================================================================
# AWS ACCOUNT / REGION
# =============================================================================

output "aws_account_id" {
  description = "AWS account ID where the infrastructure is deployed."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.region
}