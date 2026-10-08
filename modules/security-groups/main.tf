# =============================================================================
# Employee Management - Security Groups Module
# =============================================================================
# Creates dedicated security groups for:
#
# 1. EKS Worker Nodes
# 2. PostgreSQL
# 3. NGINX Ingress / Network Load Balancer
#
# NGINX Ingress is exposed through an AWS Network Load Balancer (NLB).
#
# EKS control-plane security-group management is handled by Amazon EKS.
#
# All taggable AWS resources use meaningful and consistent tags.
# =============================================================================


# =============================================================================
# EKS WORKER NODE SECURITY GROUP
# =============================================================================

resource "aws_security_group" "eks_node" {
  name        = "${var.project_name}-eks-node-sg"
  description = "Security group for Employee Management EKS worker nodes."
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-eks-node-sg"
      Module    = "Security Groups"
      Component = "EKS Worker Nodes"
      Resource  = "Security Group"
      Purpose   = "Controls network traffic for EKS worker nodes"
      Role      = "EKS Worker Nodes"
    }
  )
}


# =============================================================================
# POSTGRESQL SECURITY GROUP
# =============================================================================

resource "aws_security_group" "postgres" {
  name        = "${var.project_name}-postgres-sg"
  description = "Security group for the Employee Management PostgreSQL database workload."
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-postgres-sg"
      Module    = "Security Groups"
      Component = "PostgreSQL"
      Resource  = "Security Group"
      Purpose   = "Controls PostgreSQL database network access"
      Role      = "PostgreSQL Database"
    }
  )
}


# =============================================================================
# NGINX INGRESS / NLB SECURITY GROUP
# =============================================================================

resource "aws_security_group" "nginx_ingress" {
  name        = "${var.project_name}-nginx-ingress-sg"
  description = "Security group for the Employee Management NGINX Ingress Network Load Balancer."
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-nginx-ingress-sg"
      Module    = "Security Groups"
      Component = "NGINX Ingress"
      Resource  = "Security Group"
      Purpose   = "Controls internet traffic to the NGINX Ingress Network Load Balancer"
      Role      = "NGINX Ingress Load Balancer"
    }
  )
}


# =============================================================================
# NGINX INGRESS - HTTP
# =============================================================================

resource "aws_vpc_security_group_ingress_rule" "nginx_http" {
  security_group_id = aws_security_group.nginx_ingress.id

  description = "Allow HTTP traffic from the internet to the Employee Management NGINX Ingress Load Balancer."

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 80
  to_port   = 80

  ip_protocol = "tcp"
}


# =============================================================================
# NGINX INGRESS - HTTPS
# =============================================================================

resource "aws_vpc_security_group_ingress_rule" "nginx_https" {
  security_group_id = aws_security_group.nginx_ingress.id

  description = "Allow HTTPS traffic from the internet to the Employee Management NGINX Ingress Load Balancer."

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"
}


# =============================================================================
# NGINX INGRESS - OUTBOUND TO EKS NODES
# =============================================================================
#
# NGINX Ingress will forward traffic to Kubernetes NodePorts.
#
# The default NodePort range is:
# 30000 - 32767
#
# Therefore, this security-group rule allows NGINX/NLB traffic to reach
# Kubernetes services exposed through NodePorts.
# =============================================================================

resource "aws_vpc_security_group_egress_rule" "nginx_to_nodes" {
  security_group_id = aws_security_group.nginx_ingress.id

  description = "Allow NGINX Ingress Network Load Balancer traffic to Kubernetes NodePorts on EKS worker nodes."

  referenced_security_group_id = aws_security_group.eks_node.id

  from_port = 30000
  to_port   = 32767

  ip_protocol = "tcp"
}


# =============================================================================
# EKS NODES - INBOUND FROM NGINX INGRESS
# =============================================================================

resource "aws_vpc_security_group_ingress_rule" "node_from_nginx" {
  security_group_id = aws_security_group.eks_node.id

  description = "Allow NGINX Ingress Load Balancer traffic to Kubernetes NodePorts on EKS worker nodes."

  referenced_security_group_id = aws_security_group.nginx_ingress.id

  from_port = 30000
  to_port   = 32767

  ip_protocol = "tcp"
}


# =============================================================================
# EKS NODES - NODE TO NODE COMMUNICATION
# =============================================================================

resource "aws_vpc_security_group_ingress_rule" "node_from_nodes" {
  security_group_id = aws_security_group.eks_node.id

  description = "Allow required network communication between Employee Management EKS worker nodes."

  referenced_security_group_id = aws_security_group.eks_node.id

  ip_protocol = "-1"
}


# =============================================================================
# EKS NODES - OUTBOUND
# =============================================================================

resource "aws_vpc_security_group_egress_rule" "node_all" {
  security_group_id = aws_security_group.eks_node.id

  description = "Allow EKS worker nodes to access required AWS services and application dependencies."

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"
}


# =============================================================================
# POSTGRESQL - INBOUND FROM EKS NODES
# =============================================================================

resource "aws_vpc_security_group_ingress_rule" "postgres_from_nodes" {
  security_group_id = aws_security_group.postgres.id

  description = "Allow PostgreSQL connections only from Employee Management EKS worker nodes."

  referenced_security_group_id = aws_security_group.eks_node.id

  from_port = 5432
  to_port   = 5432

  ip_protocol = "tcp"
}


# =============================================================================
# POSTGRESQL - OUTBOUND
# =============================================================================

resource "aws_vpc_security_group_egress_rule" "postgres_all" {
  security_group_id = aws_security_group.postgres.id

  description = "Allow PostgreSQL workload outbound communication."

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"
}