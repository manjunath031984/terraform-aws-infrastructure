
# =============================================================================
# Employee Management - EKS Node Groups Module
# =============================================================================
# Creates two EKS managed node groups:
#   1. PostgreSQL workload
#   2. Employee Management application workload
#
# Design:
#   - Worker nodes run in private subnets.
#   - Existing IAM node role is reused.
#   - Existing EC2 key pair is configured through launch templates.
#   - Workload-specific labels and taints are applied.
#   - Root EBS volumes use encrypted gp3 storage.
# =============================================================================


# =============================================================================
# POSTGRESQL LAUNCH TEMPLATE
# =============================================================================

resource "aws_launch_template" "postgres" {
  name     = "${var.project_name}-postgres-lt"
  key_name = var.ec2_key_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.postgres_disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name      = "${var.project_name}-postgres-worker"
      Module    = "Node Groups"
      Component = "PostgreSQL"
      Workload  = "postgres"
      Purpose   = "Dedicated PostgreSQL EKS worker"
      Role      = "PostgreSQL Worker Node"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(var.common_tags, {
      Name      = "${var.project_name}-postgres-worker-volume"
      Module    = "Node Groups"
      Component = "PostgreSQL"
      Workload  = "postgres"
      Purpose   = "PostgreSQL worker root volume"
    })
  }

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-postgres-lt"
    Module    = "Node Groups"
    Component = "PostgreSQL"
    Resource  = "EC2 Launch Template"
    Purpose   = "Launch configuration for PostgreSQL workers"
  })
}


# =============================================================================
# POSTGRESQL NODE GROUP
# =============================================================================

resource "aws_eks_node_group" "postgres" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-postgres-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.postgres_desired_size
    min_size     = var.postgres_min_size
    max_size     = var.postgres_max_size
  }

  instance_types = var.postgres_instance_types
  capacity_type  = var.postgres_capacity_type
  ami_type       = var.postgres_ami_type

  launch_template {
    id      = aws_launch_template.postgres.id
    version = tostring(aws_launch_template.postgres.latest_version)
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    workload    = "postgres"
    component   = "database"
    application = "Employee-Management"
  }

  taint {
    key    = "workload"
    value  = "postgres"
    effect = "NO_SCHEDULE"
  }

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-postgres-ng"
    Module    = "Node Groups"
    Component = "PostgreSQL"
    Resource  = "EKS Managed Node Group"
    Purpose   = "Dedicated worker nodes for PostgreSQL"
    Role      = "PostgreSQL Worker Nodes"
    Workload  = "postgres"
    NodeGroup = "${var.project_name}-postgres-ng"
  })

  depends_on = [
    aws_launch_template.postgres
  ]

  lifecycle {
    precondition {
      condition = (
        var.postgres_min_size <= var.postgres_desired_size &&
        var.postgres_desired_size <= var.postgres_max_size
      )
      error_message = "PostgreSQL scaling must satisfy min_size <= desired_size <= max_size."
    }
  }
}


# =============================================================================
# APPLICATION LAUNCH TEMPLATE
# =============================================================================

resource "aws_launch_template" "application" {
  name     = "${var.project_name}-app-lt"
  key_name = var.ec2_key_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.application_disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name      = "${var.project_name}-app-worker"
      Module    = "Node Groups"
      Component = "Employee Management Application"
      Workload  = "application"
      Purpose   = "Dedicated application EKS worker"
      Role      = "Application Worker Node"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(var.common_tags, {
      Name      = "${var.project_name}-app-worker-volume"
      Module    = "Node Groups"
      Component = "Employee Management Application"
      Workload  = "application"
      Purpose   = "Application worker root volume"
    })
  }

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-app-lt"
    Module    = "Node Groups"
    Component = "Employee Management Application"
    Resource  = "EC2 Launch Template"
    Purpose   = "Launch configuration for application workers"
  })
}


# =============================================================================
# EMPLOYEE MANAGEMENT APPLICATION NODE GROUP
# =============================================================================

resource "aws_eks_node_group" "application" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-app-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.application_desired_size
    min_size     = var.application_min_size
    max_size     = var.application_max_size
  }

  instance_types = var.application_instance_types
  capacity_type  = var.application_capacity_type
  ami_type       = var.application_ami_type

  launch_template {
    id      = aws_launch_template.application.id
    version = tostring(aws_launch_template.application.latest_version)
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    workload    = "application"
    component   = "employee-management"
    application = "Employee-Management"
  }

  taint {
    key    = "workload"
    value  = "application"
    effect = "NO_SCHEDULE"
  }

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-app-ng"
    Module    = "Node Groups"
    Component = "Employee Management Application"
    Resource  = "EKS Managed Node Group"
    Purpose   = "Dedicated worker nodes for Employee Management application"
    Role      = "Application Worker Nodes"
    Workload  = "application"
    NodeGroup = "${var.project_name}-app-ng"
  })

  depends_on = [
    aws_launch_template.application
  ]

  lifecycle {
    precondition {
      condition = (
        var.application_min_size <= var.application_desired_size &&
        var.application_desired_size <= var.application_max_size
      )
      error_message = "Application scaling must satisfy min_size <= desired_size <= max_size."
    }
  }
}
