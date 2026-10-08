# =============================================================================
# Employee Management - IAM Module
# =============================================================================
# Creates IAM roles required by Amazon EKS:
#
# 1. EKS Cluster IAM Role
# 2. EKS Managed Node Group IAM Role
#
# EBS CSI Driver and AWS Load Balancer Controller IAM roles are intentionally
# managed by their respective modules.
# =============================================================================


# =============================================================================
# DATA SOURCES
# =============================================================================

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}


# =============================================================================
# EKS CLUSTER IAM ROLE
# =============================================================================

data "aws_iam_policy_document" "eks_cluster_assume_role" {

  statement {
    sid    = "AllowEKSServiceAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "eks.amazonaws.com"
      ]
    }
  }
}


resource "aws_iam_role" "eks_cluster" {

  name = "${var.project_name}-eks-cluster-role"

  description = "IAM role assumed by the Amazon EKS control plane for the Employee Management application."

  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-eks-cluster-role"
      Module    = "IAM"
      Component = "EKS Cluster"
      Resource  = "IAM Role"
      Purpose   = "EKS control plane permissions"
      RoleType  = "EKS Cluster Role"
      Service   = "Amazon EKS"
    }
  )
}


# =============================================================================
# EKS CLUSTER IAM POLICY ATTACHMENT
# =============================================================================

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

  role = aws_iam_role.eks_cluster.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
}


# =============================================================================
# EKS NODE IAM ROLE
# =============================================================================

data "aws_iam_policy_document" "eks_node_assume_role" {

  statement {
    sid    = "AllowEC2ServiceAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}


resource "aws_iam_role" "eks_node" {

  name = "${var.project_name}-eks-node-role"

  description = "IAM role assumed by EKS managed worker nodes for the Employee Management application."

  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-eks-node-role"
      Module    = "IAM"
      Component = "EKS Worker Nodes"
      Resource  = "IAM Role"
      Purpose   = "EKS managed node group permissions"
      RoleType  = "EKS Node Role"
      Service   = "Amazon EC2"
    }
  )
}


# =============================================================================
# EKS NODE - WORKER NODE POLICY
# =============================================================================

resource "aws_iam_role_policy_attachment" "eks_node_worker_policy" {

  role = aws_iam_role.eks_node.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


# =============================================================================
# EKS NODE - VPC CNI POLICY
# =============================================================================

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {

  role = aws_iam_role.eks_node.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
}


# =============================================================================
# EKS NODE - ECR READ-ONLY POLICY
# =============================================================================

resource "aws_iam_role_policy_attachment" "eks_node_ecr_policy" {

  role = aws_iam_role.eks_node.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}