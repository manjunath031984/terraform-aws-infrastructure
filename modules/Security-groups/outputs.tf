output "security_group_id" {
  description = "Jenkins security group ID"
  value       = aws_security_group.jenkins.id
}

output "security_group_name" {
  description = "Jenkins security group name"
  value       = aws_security_group.jenkins.name
}