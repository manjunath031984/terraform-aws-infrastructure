# =============================================================================
# Employee Management - EKS Node Groups Module Outputs
# =============================================================================


# =============================================================================
# POSTGRESQL NODE GROUP
# =============================================================================

output "postgres_node_group_name" {
  description = "Name of the PostgreSQL EKS managed node group."

  value = aws_eks_node_group.postgres.node_group_name
}


output "postgres_node_group_arn" {
  description = "ARN of the PostgreSQL EKS managed node group."

  value = aws_eks_node_group.postgres.arn
}


output "postgres_node_group_id" {
  description = "ID of the PostgreSQL EKS managed node group."

  value = aws_eks_node_group.postgres.id
}


output "postgres_node_group_status" {
  description = "Current status of the PostgreSQL EKS managed node group."

  value = aws_eks_node_group.postgres.status
}


# =============================================================================
# APPLICATION NODE GROUP
# =============================================================================

output "application_node_group_name" {
  description = "Name of the Employee Management application EKS managed node group."

  value = aws_eks_node_group.application.node_group_name
}


output "application_node_group_arn" {
  description = "ARN of the Employee Management application EKS managed node group."

  value = aws_eks_node_group.application.arn
}


output "application_node_group_id" {
  description = "ID of the Employee Management application EKS managed node group."

  value = aws_eks_node_group.application.id
}


output "application_node_group_status" {
  description = "Current status of the Employee Management application EKS managed node group."

  value = aws_eks_node_group.application.status
}