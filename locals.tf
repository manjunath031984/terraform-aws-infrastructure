locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Region      = var.aws_region
  }

  ec2_tags = {
    Name        = "jenkins-ci-cd-server"
    Component   = "jenkins"
    Application = "Jenkins"
    Environment = var.environment
  }

  security_group_tags = {
    Name        = "jenkins-ci-cd-security-group"
    Component   = "security"
    Application = "Jenkins"
    Environment = var.environment
  }
}