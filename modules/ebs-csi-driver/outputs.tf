# =============================================================================
# Employee Management - EBS CSI Driver Module Outputs
# =============================================================================


# =============================================================================
# IAM ROLE
# =============================================================================

output "role_name" {
  description = "Name of the IAM role used by the Amazon EBS CSI Driver."

  value = aws_iam_role.ebs_csi.name
}


output "role_arn" {
  description = "ARN of the IAM role used by the Amazon EBS CSI Driver."

  value = aws_iam_role.ebs_csi.arn
}


output "role_id" {
  description = "Unique ID of the IAM role used by the Amazon EBS CSI Driver."

  value = aws_iam_role.ebs_csi.id
}


# =============================================================================
# EBS CSI EKS ADD-ON
# =============================================================================

output "addon_id" {
  description = "ID of the Amazon EBS CSI Driver EKS add-on."

  value = aws_eks_addon.ebs_csi.id
}


output "addon_arn" {
  description = "ARN of the Amazon EBS CSI Driver EKS add-on."

  value = aws_eks_addon.ebs_csi.arn
}


output "addon_version" {
  description = "Installed version of the Amazon EBS CSI Driver EKS add-on."

  value = aws_eks_addon.ebs_csi.addon_version
}