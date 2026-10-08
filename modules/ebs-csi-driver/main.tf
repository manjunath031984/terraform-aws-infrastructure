# =============================================================================
# Employee Management - EBS CSI Driver Module
# =============================================================================
# Creates:
#
# 1. IAM role for the Amazon EBS CSI Driver
# 2. Amazon EBS CSI Driver EKS add-on
#
# The role is managed separately from the main IAM module because the
# EBS CSI Driver has its own workload-specific permissions.
#
# All taggable AWS resources use meaningful and consistent tags.
# =============================================================================


# =============================================================================
# EBS CSI DRIVER ASSUME ROLE POLICY
# =============================================================================

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    sid    = "AllowEKSServiceAccountAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        var.oidc_provider_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_issuer_hostpath}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_issuer_hostpath}:sub"

      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      ]
    }
  }
}


# =============================================================================
# EBS CSI DRIVER IAM ROLE
# =============================================================================

resource "aws_iam_role" "ebs_csi" {
  name = "${var.project_name}-ebs-csi-role"

  description = "IAM role used by the Amazon EBS CSI Driver for Employee Management EKS."

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-ebs-csi-role"
      Module    = "EBS CSI Driver"
      Component = "EBS CSI"
      Resource  = "IAM Role"
      Purpose   = "Provides EBS volume management permissions to the EBS CSI Driver"
      RoleType  = "EBS CSI Driver Role"
      Service   = "Amazon EKS"
    }
  )
}


# =============================================================================
# EBS CSI DRIVER IAM POLICY
# =============================================================================

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role = aws_iam_role.ebs_csi.name

  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


# =============================================================================
# EBS CSI DRIVER EKS ADD-ON
# =============================================================================

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = var.cluster_name

  addon_name    = "aws-ebs-csi-driver"
  addon_version = var.addon_version

  service_account_role_arn = aws_iam_role.ebs_csi.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-ebs-csi-addon"
      Module    = "EBS CSI Driver"
      Component = "EBS CSI"
      Resource  = "EKS Add-on"
      Purpose   = "Provides persistent EBS storage for Kubernetes workloads"
      Role      = "EKS Persistent Storage"
      Addon     = "aws-ebs-csi-driver"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi
  ]
}