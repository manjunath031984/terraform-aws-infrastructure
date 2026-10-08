# =============================================================================
# Employee Management - Security Groups Module Outputs
# =============================================================================


# =============================================================================
# EKS NODE SECURITY GROUP
# =============================================================================

output "eks_node_security_group_id" {
  description = "ID of the security group assigned to EKS worker nodes."

  value = aws_security_group.eks_node.id
}


output "eks_node_security_group_name" {
  description = "Name of the security group assigned to EKS worker nodes."

  value = aws_security_group.eks_node.name
}


# =============================================================================
# POSTGRESQL SECURITY GROUP
# =============================================================================

output "postgres_security_group_id" {
  description = "ID of the security group assigned to PostgreSQL."

  value = aws_security_group.postgres.id
}


output "postgres_security_group_name" {
  description = "Name of the security group assigned to PostgreSQL."

  value = aws_security_group.postgres.name
}


# =============================================================================
# NGINX INGRESS SECURITY GROUP
# =============================================================================

output "nginx_ingress_security_group_id" {
  description = "ID of the security group assigned to the NGINX Ingress Network Load Balancer."

  value = aws_security_group.nginx_ingress.id
}


output "nginx_ingress_security_group_name" {
  description = "Name of the security group assigned to the NGINX Ingress Network Load Balancer."

  value = aws_security_group.nginx_ingress.name
}