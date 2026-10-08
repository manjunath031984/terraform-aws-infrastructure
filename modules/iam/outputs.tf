# =============================================================================
# Employee Management - IAM Module Outputs
# =============================================================================


# =============================================================================
# EKS CLUSTER ROLE
# =============================================================================

output "eks_cluster_role_name" {
  description = "Name of the IAM role used by the EKS control plane."

  value = aws_iam_role.eks_cluster.name
}


output "eks_cluster_role_arn" {
  description = "ARN of the IAM role used by the EKS control plane."

  value = aws_iam_role.eks_cluster.arn
}


output "eks_cluster_role_id" {
  description = "Unique ID of the EKS cluster IAM role."

  value = aws_iam_role.eks_cluster.id
}


# =============================================================================
# EKS NODE ROLE
# =============================================================================

output "eks_node_role_name" {
  description = "Name of the IAM role used by EKS managed worker nodes."

  value = aws_iam_role.eks_node.name
}


output "eks_node_role_arn" {
  description = "ARN of the IAM role used by EKS managed worker nodes."

  value = aws_iam_role.eks_node.arn
}


output "eks_node_role_id" {
  description = "Unique ID of the EKS worker node IAM role."

  value = aws_iam_role.eks_node.id
}


# =============================================================================
# ACCOUNT INFORMATION
# =============================================================================

output "account_id" {
  description = "AWS account ID where the IAM resources are created."

  value = data.aws_caller_identity.current.account_id
}