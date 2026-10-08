# =============================================================================
# Employee Management - EKS Module
# =============================================================================
# Creates the Amazon EKS control plane.
#
# Responsibilities:
# - EKS cluster
# - Private subnet placement
# - Kubernetes service CIDR
# - EKS control-plane logging
# - Optional Kubernetes secrets encryption with KMS
#
# Worker nodes are intentionally managed by the node-groups module.
# EBS CSI and NGINX Ingress are intentionally managed by their own modules.
# =============================================================================


# =============================================================================
# EKS CLUSTER
# =============================================================================

resource "aws_eks_cluster" "this" {
  name     = "${var.project_name}-eks"
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  # ---------------------------------------------------------------------------
  # EKS CONTROL PLANE NETWORKING
  # ---------------------------------------------------------------------------

  vpc_config {
    subnet_ids = var.private_subnet_ids

    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access

    public_access_cidrs = var.public_access_cidrs
  }

  # ---------------------------------------------------------------------------
  # KUBERNETES NETWORK CONFIGURATION
  # ---------------------------------------------------------------------------

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }

  # ---------------------------------------------------------------------------
  # CONTROL PLANE LOGGING
  # ---------------------------------------------------------------------------

  enabled_cluster_log_types = var.enabled_cluster_log_types

  # ---------------------------------------------------------------------------
  # OPTIONAL KMS ENCRYPTION
  # ---------------------------------------------------------------------------
  # When a KMS key ARN is supplied, Kubernetes Secrets are encrypted
  # at rest using the customer-managed KMS key.
  # ---------------------------------------------------------------------------

  dynamic "encryption_config" {
    for_each = var.kms_key_arn != null ? [var.kms_key_arn] : []

    content {
      provider {
        key_arn = encryption_config.value
      }

      resources = [
        "secrets"
      ]
    }
  }

  # ---------------------------------------------------------------------------
  # RESOURCE TAGS
  # ---------------------------------------------------------------------------

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-eks"
      Module    = "EKS"
      Component = "EKS Control Plane"
      Resource  = "EKS Cluster"
      Purpose   = "Managed Kubernetes control plane for Employee Management"
      Role      = "EKS Control Plane"
    }
  )

  # ---------------------------------------------------------------------------
  # PREVENT TERRAFORM FROM REMOVING LOG CONFIGURATION UNEXPECTEDLY
  # ---------------------------------------------------------------------------

  lifecycle {
    precondition {
      condition = length(var.private_subnet_ids) >= 2

      error_message = "The EKS cluster requires at least two private subnets in different Availability Zones."
    }

    precondition {
      condition = var.endpoint_public_access || var.endpoint_private_access

      error_message = "At least one EKS API endpoint access mode must be enabled."
    }
  }
}