
# =============================================================================
# Employee Management - VPC Module
# =============================================================================

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-vpc"
      Module    = "VPC"
      Component = "Network"
      Purpose   = "Primary VPC for Employee Management EKS infrastructure"
      Resource  = "VPC"
    }
  )
}

# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-igw"
      Module    = "VPC"
      Component = "Internet Gateway"
      Purpose   = "Provides internet connectivity for public subnets"
      Resource  = "InternetGateway"
    }
  )
}

# =============================================================================
# PUBLIC SUBNETS
# =============================================================================

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name                     = each.value.name
      Module                   = "VPC"
      Component                = "Public Subnet"
      Purpose                  = "Public subnet for AWS Load Balancers and internet-facing resources"
      Resource                 = "Subnet"
      Type                     = "Public"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

# =============================================================================
# PRIVATE SUBNETS
# =============================================================================

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name                              = each.value.name
      Module                            = "VPC"
      Component                         = "Private Subnet"
      Purpose                           = "Private subnet for EKS worker nodes and application workloads"
      Resource                          = "Subnet"
      Type                              = "Private"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

# =============================================================================
# ELASTIC IP ADDRESSES FOR NAT GATEWAYS
# =============================================================================

resource "aws_eip" "nat" {
  for_each = var.public_subnets

  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-nat-eip-${each.value.name}"
      Module    = "VPC"
      Component = "NAT Gateway Elastic IP"
      Purpose   = "Elastic IP address for NAT Gateway"
      Resource  = "ElasticIP"
    }
  )

  depends_on = [
    aws_internet_gateway.this
  ]
}

# =============================================================================
# NAT GATEWAYS
# =============================================================================

resource "aws_nat_gateway" "this" {
  for_each = var.public_subnets

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-nat-${each.value.name}"
      Module    = "VPC"
      Component = "NAT Gateway"
      Purpose   = "Provides outbound internet access for private subnets"
      Resource  = "NATGateway"
    }
  )

  depends_on = [
    aws_internet_gateway.this
  ]
}

# =============================================================================
# PUBLIC ROUTE TABLE
# =============================================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-public-rt"
      Module    = "VPC"
      Component = "Public Route Table"
      Purpose   = "Routes public subnet traffic to the Internet Gateway"
      Resource  = "RouteTable"
      Type      = "Public"
    }
  )
}

# -----------------------------------------------------------------------------
# Public Route - Internet Gateway
# -----------------------------------------------------------------------------

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# -----------------------------------------------------------------------------
# Associate Public Subnets
# -----------------------------------------------------------------------------

resource "aws_route_table_association" "public" {
  for_each = var.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# PRIVATE ROUTE TABLES
# =============================================================================

resource "aws_route_table" "private" {
  for_each = var.private_subnets

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name      = "${each.value.name}-rt"
      Module    = "VPC"
      Component = "Private Route Table"
      Purpose   = "Routes private subnet outbound traffic through NAT Gateway"
      Resource  = "RouteTable"
      Type      = "Private"
    }
  )
}

# -----------------------------------------------------------------------------
# Private Routes - NAT Gateway
# -----------------------------------------------------------------------------

resource "aws_route" "private_nat" {
  for_each = var.private_subnets

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.value.nat_gateway_key].id
}

# -----------------------------------------------------------------------------
# Associate Private Subnets
# -----------------------------------------------------------------------------

resource "aws_route_table_association" "private" {
  for_each = var.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
