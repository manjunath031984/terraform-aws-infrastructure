output "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = module.ec2.instance_id
}

output "jenkins_public_ip" {
  description = "Jenkins EC2 public IP"
  value       = module.ec2.instance_public_ip
}

output "jenkins_public_dns" {
  description = "Jenkins EC2 public DNS"
  value       = module.ec2.instance_public_dns
}

output "jenkins_private_ip" {
  description = "Jenkins EC2 private IP"
  value       = module.ec2.instance_private_ip
}

output "jenkins_security_group_id" {
  description = "Jenkins security group ID"
  value       = module.security_groups.security_group_id
}

output "jenkins_security_group_name" {
  description = "Jenkins security group name"
  value       = module.security_groups.security_group_name
}

output "jenkins_key_pair_name" {
  description = "Existing Jenkins EC2 key pair"
  value       = module.key_pair.key_pair_name
}