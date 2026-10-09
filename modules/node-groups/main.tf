
# =============================================================================
# Employee Management - EKS Node Groups Module
# =============================================================================
# Creates EKS managed node groups for:
# 1. PostgreSQL workload
# 2. Employee Management application workload
#
# Design:
# - Two managed node groups
# - One node per workload
# - Nodes deployed into private subnets
# - Workload-specific labels and taints
# - Existing IAM role is reused
#
# NOTE:
# This is a cost-conscious design and is NOT highly available.
# =============================================================================


# =============================================================================
# POSTGRESQL NODE GROUP
# =============================================================================

resource "aws_eks_node_group" "postgres" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-postgres-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  # ---------------------------------------------------------------------------
  # SCALING CONFIGURATION
  # ---------------------------------------------------------------------------

  scaling_config {
    desired_size = var.postgres_desired_size
    min_size     = var.postgres_min_size
    max_size     = var.postgres_max_size
  }

  # ---------------------------------------------------------------------------
  # INSTANCE CONFIGURATION
  # ---------------------------------------------------------------------------

  instance_types = var.postgres_instance_types
  capacity_type  = var.postgres_capacity_type
  disk_size      = var.postgres_disk_size
  ami_type       = var.postgres_ami_type

  # ---------------------------------------------------------------------------
  # UPDATE CONFIGURATION
  # ---------------------------------------------------------------------------

  update_config {
    max_unavailable = 1
  }

  # ---------------------------------------------------------------------------
  # WORKLOAD LABELS
  # ---------------------------------------------------------------------------

  labels = {
    workload    = "postgres"
    component   = "database"
    application = "Employee-Management"
  }

  # ---------------------------------------------------------------------------
  # WORKLOAD TAINT
  # ---------------------------------------------------------------------------

  taint {
    key    = "workload"
    value  = "postgres"
    effect = "NO_SCHEDULE"
  }

  # ---------------------------------------------------------------------------
  # RESOURCE TAGS
  # ---------------------------------------------------------------------------

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-postgres-ng"
      Module    = "Node Groups"
      Component = "PostgreSQL"
      Resource  = "EKS Managed Node Group"
      Purpose   = "Dedicated worker nodes for PostgreSQL"
      Role      = "PostgreSQL Worker Nodes"
      Workload  = "postgres"
      NodeGroup = "${var.project_name}-postgres-ng"
    }
  )
}


# =============================================================================
# EMPLOYEE MANAGEMENT APPLICATION NODE GROUP
# =============================================================================

resource "aws_eks_node_group" "application" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-app-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  # ---------------------------------------------------------------------------
  # SCALING CONFIGURATION
  # ---------------------------------------------------------------------------

  scaling_config {
    desired_size = var.application_desired_size
    min_size     = var.application_min_size
    max_size     = var.application_max_size
  }

  # ---------------------------------------------------------------------------
  # INSTANCE CONFIGURATION
  # ---------------------------------------------------------------------------

  instance_types = var.application_instance_types
  capacity_type  = var.application_capacity_type
  disk_size      = var.application_disk_size
  ami_type       = var.application_ami_type

  # ---------------------------------------------------------------------------
  # UPDATE CONFIGURATION
  # ---------------------------------------------------------------------------

  update_config {
    max_unavailable = 1
  }

  # ---------------------------------------------------------------------------
  # WORKLOAD LABELS
  # ---------------------------------------------------------------------------

  labels = {
    workload    = "application"
    component   = "employee-management"
    application = "Employee-Management"
  }

  # ---------------------------------------------------------------------------
  # WORKLOAD TAINT
  # ---------------------------------------------------------------------------

  taint {
    key    = "workload"
    value  = "application"
    effect = "NO_SCHEDULE"
  }

  # ---------------------------------------------------------------------------
  # RESOURCE TAGS
  # ---------------------------------------------------------------------------

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-app-ng"
      Module    = "Node Groups"
      Component = "Employee Management Application"
      Resource  = "EKS Managed Node Group"
      Purpose   = "Dedicated worker nodes for Employee Management application"
      Role      = "Application Worker Nodes"
      Workload  = "application"
      NodeGroup = "${var.project_name}-app-ng"
    }
  )
}


# =============================================================================
# DISCOVER POSTGRESQL AUTO SCALING GROUPS
# =============================================================================

data "aws_autoscaling_groups" "postgres" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [var.cluster_name]
  }

  filter {
    name   = "tag:eks:nodegroup-name"
    values = ["${var.project_name}-postgres-ng"]
  }

  depends_on = [
    aws_eks_node_group.postgres
  ]
}


# =============================================================================
# DISCOVER APPLICATION AUTO SCALING GROUPS
# =============================================================================

data "aws_autoscaling_groups" "application" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [var.cluster_name]
  }

  filter {
    name   = "tag:eks:nodegroup-name"
    values = ["${var.project_name}-app-ng"]
  }

  depends_on = [
    aws_eks_node_group.application
  ]
}


# =============================================================================
# EC2 INSTANCE NAME TAGS - POSTGRESQL WORKERS
# =============================================================================

resource "aws_autoscaling_group_tag" "postgres_instance_name" {
  for_each = toset(data.aws_autoscaling_groups.postgres.names)

  autoscaling_group_name = each.value

  tag {
    key                 = "Name"
    value               = "${var.project_name}-postgres-worker"
    propagate_at_launch = true
  }
}


# =============================================================================
# EC2 INSTANCE NAME TAGS - APPLICATION WORKERS
# =============================================================================

resource "aws_autoscaling_group_tag" "application_instance_name" {
  for_each = toset(data.aws_autoscaling_groups.application.names)

  autoscaling_group_name = each.value

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-worker"
    propagate_at_launch = true
  }
}
