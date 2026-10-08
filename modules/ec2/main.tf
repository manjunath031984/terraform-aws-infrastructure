resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type

  key_name = var.key_pair_name

  vpc_security_group_ids = var.security_group_ids

  associate_public_ip_address = true

  monitoring = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(
    var.tags,
    {
      Name = "jenkins-ci-cd-server"
    }
  )
}