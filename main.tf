
module "vpc" {
  source = "./modules/vpc"

  project_name     = var.project_name
  environment      = var.environment
  eks_cluster_name = var.eks_cluster_name

  vpc_cidr = var.vpc_cidr

  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  tags = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  subnet_ids = module.vpc.private_subnet_ids

  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.eks_api_allowed_cidrs

  tags = local.common_tags
}

module "eks_node_groups" {
  source = "./modules/node-groups"

  cluster_name       = module.eks.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids

  node_role_name = "${var.eks_cluster_name}-node-role"

  postgres_instance_types = var.postgres_instance_types
  employee_instance_types = var.employee_instance_types

  disk_size = var.node_disk_size

  tags = local.common_tags

  depends_on = [
    module.eks
  ]
}

module "eks_addons" {
  source = "./modules/eks-addons"

  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.oidc_issuer_url

  ebs_csi_role_name = "${var.eks_cluster_name}-ebs-csi-role"

  tags = local.common_tags

  depends_on = [
    module.eks
  ]
}

module "nginx_ingress" {
  source = "./modules/nginx-ingress"

  namespace     = "ingress-nginx"
  release_name  = "ingress-nginx"
  chart_version = "4.13.3"
  scheme        = "internet-facing"
}

