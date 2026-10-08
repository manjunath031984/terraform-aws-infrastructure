# =============================================================================
# Employee Management - EKS Add-ons Module
# =============================================================================
# Manages the core Amazon EKS add-ons:
#
# 1. VPC CNI
# 2. CoreDNS
# 3. kube-proxy
#
# EBS CSI Driver and NGINX Ingress Controller are intentionally managed
# by their respective modules.
#
# All taggable AWS resources use meaningful and consistent tags.
# =============================================================================


# =============================================================================
# VPC CNI
# =============================================================================

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.cluster_name

  addon_name    = "vpc-cni"
  addon_version = var.vpc_cni_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-vpc-cni-addon"
      Module    = "EKS Add-ons"
      Component = "VPC CNI"
      Resource  = "EKS Add-on"
      Purpose   = "Provides Kubernetes pod networking using the Amazon VPC CNI plugin"
      Role      = "EKS Networking"
      Addon     = "vpc-cni"
    }
  )
}


# =============================================================================
# COREDNS
# =============================================================================

resource "aws_eks_addon" "coredns" {
  cluster_name = var.cluster_name

  addon_name    = "coredns"
  addon_version = var.coredns_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-coredns-addon"
      Module    = "EKS Add-ons"
      Component = "CoreDNS"
      Resource  = "EKS Add-on"
      Purpose   = "Provides DNS-based service discovery inside the Kubernetes cluster"
      Role      = "EKS DNS"
      Addon     = "coredns"
    }
  )
}


# =============================================================================
# KUBE-PROXY
# =============================================================================

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = var.cluster_name

  addon_name    = "kube-proxy"
  addon_version = var.kube_proxy_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-kube-proxy-addon"
      Module    = "EKS Add-ons"
      Component = "kube-proxy"
      Resource  = "EKS Add-on"
      Purpose   = "Provides Kubernetes Service networking on EKS worker nodes"
      Role      = "EKS Service Networking"
      Addon     = "kube-proxy"
    }
  )
}