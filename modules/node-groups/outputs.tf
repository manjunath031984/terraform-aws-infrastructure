
output "node_role_arn" {
  description = "IAM role ARN shared by both managed node groups"
  value       = aws_iam_role.nodes.arn
}

output "node_role_name" {
  description = "IAM role name for EKS worker nodes"
  value       = aws_iam_role.nodes.name
}

output "postgres_node_group_name" {
  description = "PostgreSQL managed node group name"
  value       = aws_eks_node_group.postgres.node_group_name
}

output "postgres_node_group_arn" {
  description = "PostgreSQL managed node group ARN"
  value       = aws_eks_node_group.postgres.arn
}

output "employee_node_group_name" {
  description = "Employee Management managed node group name"
  value       = aws_eks_node_group.employee.node_group_name
}

output "employee_node_group_arn" {
  description = "Employee Management managed node group ARN"
  value       = aws_eks_node_group.employee.arn
}

output "postgres_node_group_status" {
  description = "PostgreSQL node group status"
  value       = aws_eks_node_group.postgres.status
}

output "employee_node_group_status" {
  description = "Employee Management node group status"
  value       = aws_eks_node_group.employee.status
}
