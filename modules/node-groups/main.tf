
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# IAM trust policy for EC2 worker nodes
data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "nodes" {
  name               = var.node_role_name
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
  tags               = var.tags
}

# Permissions required by EKS worker nodes
resource "aws_iam_role_policy_attachment" "worker_node" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

# Simple learning setup: VPC CNI permissions on the node role.
# For production, consider assigning CNI permissions to a
# dedicated role for the aws-node service account.
resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# PostgreSQL node group: private subnet in AZ A
resource "aws_eks_node_group" "postgres" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-postgres"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [var.private_subnet_ids[0]]

  instance_types = var.postgres_instance_types
  disk_size      = var.disk_size
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    workload = "postgres"
  }

  taint {
    key    = "workload"
    value  = "postgres"
    effect = "NO_SCHEDULE"
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.worker_node,
    aws_iam_role_policy_attachment.ecr_pull,
    aws_iam_role_policy_attachment.vpc_cni
  ]
}

# Employee Management node group: private subnet in AZ B
resource "aws_eks_node_group" "employee" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-employee"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [var.private_subnet_ids[1]]

  instance_types = var.employee_instance_types
  disk_size      = var.disk_size
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    workload = "employee"
  }

  taint {
    key    = "workload"
    value  = "employee"
    effect = "NO_SCHEDULE"
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.worker_node,
    aws_iam_role_policy_attachment.ecr_pull,
    aws_iam_role_policy_attachment.vpc_cni
  ]
}
