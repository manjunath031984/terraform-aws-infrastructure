resource "aws_security_group" "jenkins" {
  name        = var.security_group_name
  description = "Security group for Jenkins CI/CD server"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = var.security_group_name
      Description = "Security group for Jenkins CI/CD server"
    }
  )
}

# ---------------------------------------------------------
# SSH - Port 22
# ---------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.jenkins.id

  cidr_ipv4   = var.ssh_allowed_cidr[0]
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  description = "SSH access for EC2 administration"
}

# ---------------------------------------------------------
# HTTP - Port 80
# ---------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.jenkins.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "HTTP web traffic for Jenkins reverse proxy"
}

# ---------------------------------------------------------
# HTTPS - Port 443
# ---------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.jenkins.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "HTTPS secure web traffic for Jenkins"
}

# ---------------------------------------------------------
# Jenkins - Port 8080
# ---------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "jenkins" {
  security_group_id = aws_security_group.jenkins.id

  cidr_ipv4   = var.jenkins_allowed_cidr[0]
  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"

  description = "Jenkins web interface access"
}

# ---------------------------------------------------------
# Outbound - Allow all
# ---------------------------------------------------------

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.jenkins.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow outbound internet traffic"
}