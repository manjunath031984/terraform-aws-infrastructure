# =============================================================================
# Employee Management - VPC Module Outputs
# =============================================================================


# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the Employee Management VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the Employee Management VPC."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the Employee Management VPC."
  value       = aws_vpc.this.cidr_block
}


# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}


# -----------------------------------------------------------------------------
# Public Subnets
# -----------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "Map of public subnet names to subnet IDs."

  value = {
    for key, subnet in aws_subnet.public :
    key => subnet.id
  }
}

output "public_subnet_cidr_blocks" {
  description = "Map of public subnet names to CIDR blocks."

  value = {
    for key, subnet in aws_subnet.public :
    key => subnet.cidr_block
  }
}


# -----------------------------------------------------------------------------
# Private Subnets
# -----------------------------------------------------------------------------

output "private_subnet_ids" {
  description = "Map of private subnet names to subnet IDs."

  value = {
    for key, subnet in aws_subnet.private :
    key => subnet.id
  }
}

output "private_subnet_cidr_blocks" {
  description = "Map of private subnet names to CIDR blocks."

  value = {
    for key, subnet in aws_subnet.private :
    key => subnet.cidr_block
  }
}


# -----------------------------------------------------------------------------
# NAT Gateways
# -----------------------------------------------------------------------------

output "nat_gateway_ids" {
  description = "Map of NAT Gateway names to NAT Gateway IDs."

  value = {
    for key, nat in aws_nat_gateway.this :
    key => nat.id
  }
}

output "nat_gateway_public_ips" {
  description = "Map of NAT Gateway names to Elastic public IP addresses."

  value = {
    for key, eip in aws_eip.nat :
    key => eip.public_ip
  }
}


# -----------------------------------------------------------------------------
# Route Tables
# -----------------------------------------------------------------------------

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Map of private subnet names to private route table IDs."

  value = {
    for key, route_table in aws_route_table.private :
    key => route_table.id
  }
}


# -----------------------------------------------------------------------------
# Availability Zones
# -----------------------------------------------------------------------------

output "availability_zones" {
  description = "Availability Zones used by the VPC."

  value = distinct([
    for subnet in var.public_subnets :
    subnet.availability_zone
  ])
}