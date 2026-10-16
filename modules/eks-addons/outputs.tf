
output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for the EKS cluster"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN used by the EBS CSI Driver"
  value       = aws_iam_role.ebs_csi.arn
}

output "ebs_csi_addon_arn" {
  description = "ARN of the EKS-managed EBS CSI Driver add-on"
  value       = aws_eks_addon.ebs_csi.arn
}
