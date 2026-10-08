# =============================================================================
# Employee Management - Terraform Providers
# =============================================================================


# =============================================================================
# AWS PROVIDER
# =============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}


# =============================================================================
# KUBERNETES PROVIDER
# =============================================================================
# Connects Terraform to the EKS cluster created by the EKS module.
#
# The Kubernetes provider uses the AWS CLI authentication mechanism through
# exec, so the Jenkins/EC2 environment must have AWS CLI configured with
# permission to access the EKS cluster.
# =============================================================================

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"

    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.aws_region
    ]
  }
}


# =============================================================================
# HELM PROVIDER
# =============================================================================

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        var.aws_region
      ]
    }
  }
}