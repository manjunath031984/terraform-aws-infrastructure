output "key_pair_name" {
  description = "Existing EC2 key pair name"
  value       = data.aws_key_pair.existing.key_name
}

output "key_pair_id" {
  description = "Existing EC2 key pair ID"
  value       = data.aws_key_pair.existing.id
}