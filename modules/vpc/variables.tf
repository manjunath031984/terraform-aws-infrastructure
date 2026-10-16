
variable "project_name" {
  description = "Name prefix for AWS resources"
  type        = string
  default     = "employee-management"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Exactly two Availability Zones in the selected region"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Provide exactly two Availability Zones."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public ALB subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Provide exactly two public subnet CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private EKS worker subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Provide exactly two private subnet CIDRs."
  }
}

variable "enable_nat_gateway" {
  description = "Create a NAT Gateway for private subnet outbound access"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway instead of one per AZ"
  type        = bool
  default     = true
}

variable "eks_cluster_name" {
  description = "EKS cluster name used for subnet discovery tags"
  type        = string
  default     = "employee-management-eks"
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}
