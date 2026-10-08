# =============================================================================
# Employee Management - EKS Module Outputs
# =============================================================================


# =============================================================================
# EKS CLUSTER
# =============================================================================

output "cluster_id" {
  description = "ID of the Amazon EKS cluster."

  value = aws_eks_cluster.this.id
}


output "cluster_name" {
  description = "Name of the Amazon EKS cluster."

  value = aws_eks_cluster.this.name
}


output "cluster_arn" {
  description = "ARN of the Amazon EKS cluster."

  value = aws_eks_cluster.this.arn
}


# =============================================================================
# EKS API ENDPOINT
# =============================================================================

output "cluster_endpoint" {
  description = "Endpoint URL of the Amazon EKS Kubernetes API server."

  value = aws_eks_cluster.this.endpoint
}


# =============================================================================
# EKS PLATFORM
# =============================================================================

output "cluster_platform_version" {
  description = "Platform version of the Amazon EKS control plane."

  value = aws_eks_cluster.this.platform_version
}


output "cluster_version" {
  description = "Kubernetes version running on the Amazon EKS cluster."

  value = aws_eks_cluster.this.version
}


# =============================================================================
# EKS CLUSTER SECURITY GROUP
# =============================================================================

output "cluster_security_group_id" {
  description = "Security group automatically created and managed by Amazon EKS for the cluster."

  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}


# =============================================================================
# EKS VPC CONFIGURATION
# =============================================================================

output "cluster_vpc_id" {
  description = "VPC ID associated with the Amazon EKS cluster."

  value = aws_eks_cluster.this.vpc_config[0].vpc_id
}


output "cluster_subnet_ids" {
  description = "Subnet IDs associated with the Amazon EKS cluster."

  value = aws_eks_cluster.this.vpc_config[0].subnet_ids
}


# =============================================================================
# KUBERNETES NETWORK
# =============================================================================

output "service_ipv4_cidr" {
  description = "IPv4 CIDR used by Kubernetes services inside the EKS cluster."

  value = aws_eks_cluster.this.kubernetes_network_config[0].service_ipv4_cidr
}


# =============================================================================
# EKS OIDC ISSUER
# =============================================================================
# Used later by IAM/IRSA-based integrations such as EBS CSI or other
# Kubernetes AWS integrations if required.
# =============================================================================

output "oidc_issuer_url" {
  description = "OIDC issuer URL of the Amazon EKS cluster."

  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for the EKS cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}