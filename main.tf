#Employee Management - Root Terraform Configuration
# =============================================================================
# Wires all infrastructure modules together.
#
# Architecture:
#
# Internet
#    |
#    v
# AWS Network Load Balancer
#    |
#    v
# NGINX Ingress Controller
#    |
#    v
# Employee Management Kubernetes Service
#    |
#    v
# Employee Management Application Pod
#
# EKS Workloads:
#   Application node group -> workload=application
#   PostgreSQL node group  -> workload=postgres
#
# Worker nodes run in private subnets.
# =============================================================================


# =============================================================================
# VPC
# =============================================================================

module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr

  public_subnets = {
    public_az1 = {
      cidr              = "10.0.1.0/24"
      availability_zone = "us-east-1a"
      name              = "${var.project_name}-public-az1"
    }

    public_az2 = {
      cidr              = "10.0.2.0/24"
      availability_zone = "us-east-1b"
      name              = "${var.project_name}-public-az2"
    }
  }

  private_subnets = {
    private_az1 = {
      cidr              = "10.0.11.0/24"
      availability_zone = "us-east-1a"
      name              = "${var.project_name}-private-az1"
      nat_gateway_key   = "public_az1"
    }

    private_az2 = {
      cidr              = "10.0.12.0/24"
      availability_zone = "us-east-1b"
      name              = "${var.project_name}-private-az2"
      nat_gateway_key   = "public_az2"
    }
  }

  common_tags = local.common_tags
}


# =============================================================================
# SECURITY GROUPS
# =============================================================================

module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  environment  = var.environment

  vpc_id           = module.vpc.vpc_id
  application_port = var.application_port

  common_tags = local.common_tags

  depends_on = [
    module.vpc
  ]
}


# =============================================================================
# IAM
# =============================================================================

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment

  common_tags = local.common_tags
}


# =============================================================================
# KMS
# =============================================================================

module "kms" {
  source = "./modules/kms"

  project_name = var.project_name
  environment  = var.environment

  deletion_window_in_days = var.kms_deletion_window_in_days
  key_policy              = data.aws_iam_policy_document.eks_kms_key_policy.json

  common_tags = local.common_tags

  depends_on = [
    module.iam
  ]
}


# =============================================================================
# EKS CLUSTER
# =============================================================================

module "eks" {
  source = "./modules/eks"

  project_name = var.project_name
  environment  = var.environment

  kubernetes_version = var.kubernetes_version

  cluster_role_arn = module.iam.eks_cluster_role_arn

  # Convert the private subnet ID map to a list for the EKS module.
  private_subnet_ids = values(module.vpc.private_subnet_ids)

  service_ipv4_cidr = var.eks_service_ipv4_cidr

  endpoint_private_access = var.eks_endpoint_private_access
  endpoint_public_access  = var.eks_endpoint_public_access
  public_access_cidrs     = var.eks_public_access_cidrs

  enabled_cluster_log_types = var.eks_enabled_cluster_log_types

  kms_key_arn = module.kms.key_arn

  common_tags = local.common_tags

  depends_on = [
    module.vpc,
    module.iam,
    module.kms
  ]
}

# =============================================================================
# EKS CLUSTER SECURITY GROUP NAME TAG
# =============================================================================
# Amazon EKS manages the cluster security group. This resource changes only
# its Name tag; it does not change the security group's actual name/description.
# =============================================================================

resource "aws_ec2_tag" "eks_cluster_security_group_name" {
  resource_id = module.eks.cluster_security_group_id

  key   = "Name"
  value = "Employee-Management-eks-cluster-sg"
}


# =============================================================================
# EKS MANAGED NODE GROUPS
# =============================================================================
# PostgreSQL:
#   Label: workload=postgres
#   Taint: workload=postgres:NoSchedule
#
# Application:
#   Label: workload=application
#   Taint: workload=application:NoSchedule
#
# Existing EC2 key pair: jenkins-ci-cd-keypair
#
# Root EBS volumes are configured through launch templates.
# =============================================================================

module "node_groups" {
  source = "./modules/node-groups"

  project_name = var.project_name
  environment  = var.environment

  cluster_name  = module.eks.cluster_name
  node_role_arn = module.iam.eks_node_role_arn

  ec2_key_name = "jenkins-ci-cd-keypair"

  private_subnet_ids = values(module.vpc.private_subnet_ids)

  # PostgreSQL node-group scaling
  postgres_desired_size = var.postgres_desired_size
  postgres_min_size     = var.postgres_min_size
  postgres_max_size     = var.postgres_max_size

  # Application node-group scaling
  application_desired_size = var.application_desired_size
  application_min_size     = var.application_min_size
  application_max_size     = var.application_max_size

  # EC2 instance types
  postgres_instance_types    = var.postgres_instance_types
  application_instance_types = var.application_instance_types

  # Capacity types
  postgres_capacity_type    = var.postgres_capacity_type
  application_capacity_type = var.application_capacity_type

  # Root EBS volume sizes
  postgres_disk_size    = var.postgres_disk_size
  application_disk_size = var.application_disk_size

  # EKS-optimized AMI types
  postgres_ami_type    = var.postgres_ami_type
  application_ami_type = var.application_ami_type

  common_tags = local.common_tags

  depends_on = [
    module.eks,
    module.iam
  ]
}


# =============================================================================
# EKS ADD-ONS
# =============================================================================

module "eks_addons" {
  source = "./modules/eks-addons"

  project_name = var.project_name
  environment  = var.environment

  cluster_name = module.eks.cluster_name

  vpc_cni_version    = var.vpc_cni_version
  coredns_version    = var.coredns_version
  kube_proxy_version = var.kube_proxy_version

  common_tags = local.common_tags

  depends_on = [
    module.eks,
    module.node_groups
  ]
}


# =============================================================================
# EKS IAM OIDC PROVIDER
# =============================================================================
# Required for IAM Roles for Service Accounts (IRSA).
# Used by the EBS CSI driver.
# =============================================================================

resource "aws_iam_openid_connect_provider" "eks" {
  url = module.eks.oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = merge(
    local.common_tags,
    {
      Name      = "${var.project_name}-eks-oidc-provider"
      Module    = "IAM"
      Component = "EKS"
      Resource  = "IAM OIDC Provider"
      Purpose   = "IRSA for EKS workloads"
    }
  )

  depends_on = [
    module.eks
  ]
}


# =============================================================================
# EBS CSI DRIVER
# =============================================================================
# Uses the EKS OIDC provider and its IAM role configuration.
# =============================================================================

module "ebs_csi_driver" {
  source = "./modules/ebs-csi-driver"

  project_name = var.project_name
  environment  = var.environment

  cluster_name = module.eks.cluster_name

  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn

  oidc_issuer_hostpath = local.eks_oidc_issuer_hostpath

  aws_partition = data.aws_partition.current.partition

  addon_version = var.ebs_csi_addon_version

  common_tags = local.common_tags

  depends_on = [
    module.eks,
    module.node_groups,
    aws_iam_openid_connect_provider.eks
  ]
}


# =============================================================================
# NGINX INGRESS CONTROLLER
# =============================================================================
# Deploys the local Helm wrapper chart:
#   ./charts/nginx-ingress/
#
# Chart configuration:
#   ./charts/nginx-ingress/values.yaml
#
# The upstream ingress-nginx dependency is declared in Chart.yaml.
# Build the dependency before Terraform plan/apply.
# =============================================================================

module "nginx_ingress" {
  source = "./modules/nginx-ingress"

  project_name = var.project_name
  environment  = var.environment

  namespace    = var.nginx_namespace
  release_name = var.nginx_release_name

  helm_timeout = var.nginx_helm_timeout

  depends_on = [
    module.eks,
    module.node_groups,
    module.eks_addons
  ]
}
