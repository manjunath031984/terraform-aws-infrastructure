# Customize the Name tag of the EKS-created cluster security group
resource "aws_ec2_tag" "cluster_security_group_name" {
  resource_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  key         = "Name"
  value       = "sg-${var.cluster_name}"
}
