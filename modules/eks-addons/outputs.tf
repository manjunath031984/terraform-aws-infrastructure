# =============================================================================
# Employee Management - EKS Add-ons Module Outputs
# =============================================================================


# =============================================================================
# VPC CNI
# =============================================================================

output "vpc_cni_id" {
  description = "ID of the Amazon VPC CNI EKS add-on."

  value = aws_eks_addon.vpc_cni.id
}


output "vpc_cni_arn" {
  description = "ARN of the Amazon VPC CNI EKS add-on."

  value = aws_eks_addon.vpc_cni.arn
}


output "vpc_cni_version" {
  description = "Installed version of the Amazon VPC CNI EKS add-on."

  value = aws_eks_addon.vpc_cni.addon_version
}


# =============================================================================
# COREDNS
# =============================================================================

output "coredns_id" {
  description = "ID of the CoreDNS EKS add-on."

  value = aws_eks_addon.coredns.id
}


output "coredns_arn" {
  description = "ARN of the CoreDNS EKS add-on."

  value = aws_eks_addon.coredns.arn
}


output "coredns_version" {
  description = "Installed version of the CoreDNS EKS add-on."

  value = aws_eks_addon.coredns.addon_version
}


# =============================================================================
# KUBE-PROXY
# =============================================================================

output "kube_proxy_id" {
  description = "ID of the kube-proxy EKS add-on."

  value = aws_eks_addon.kube_proxy.id
}


output "kube_proxy_arn" {
  description = "ARN of the kube-proxy EKS add-on."

  value = aws_eks_addon.kube_proxy.arn
}


output "kube_proxy_version" {
  description = "Installed version of the kube-proxy EKS add-on."

  value = aws_eks_addon.kube_proxy.addon_version
}