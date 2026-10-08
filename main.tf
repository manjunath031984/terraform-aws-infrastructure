# ============================================================
# Existing Key Pair
# ============================================================

module "key_pair" {
  source = "./modules/Key-pair"

  key_pair_name = var.key_pair_name
}


# ============================================================
# Jenkins Security Group
# ============================================================

module "security_groups" {
  source = "./modules/Security-groups"

  security_group_name = "jenkins-ci-cd-security-group"

  # Use the default VPC in us-east-1
  vpc_id = data.aws_vpc.default.id

  ssh_allowed_cidr     = var.ssh_allowed_cidr
  jenkins_allowed_cidr = var.jenkins_allowed_cidr

  tags = local.security_group_tags
}


# ============================================================
# Jenkins EC2 Instance
# ============================================================

module "ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type

  # Existing AWS Key Pair
  key_pair_name = module.key_pair.key_pair_name

  # Attach Jenkins Security Group
  security_group_ids = [
    module.security_groups.security_group_id
  ]

  tags = local.ec2_tags
}