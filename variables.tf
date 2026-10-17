
variable "aws_region" {
  description = "AWS region for all project resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Project name used in resource tags"
  type        = string
  default     = "employee-management"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_cluster_name" {
  description = "Amazon EKS cluster name"
  type        = string
  default     = "employee-management-eks"
}

variable "eks_cluster_version" {
  description = "Kubernetes version supported by EKS in the selected region"
  type        = string
}

variable "eks_api_allowed_cidrs" {
  description = "Trusted public IPv4 CIDRs allowed to access the EKS API"
  type        = list(string)

  validation {
    condition = (
      length(var.eks_api_allowed_cidrs) > 0 &&
      alltrue([
        for cidr in var.eks_api_allowed_cidrs :
        cidr != "0.0.0.0/0" && cidr != "::/0"
      ])
    )

    error_message = "Provide at least one trusted CIDR and do not allow all IPv4 or IPv6 addresses."
  }
}

variable "enable_nat_gateway" {
  description = "Whether private subnets have NAT Gateway outbound access"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway to reduce development costs"
  type        = bool
  default     = true
}

variable "postgres_instance_types" {
  description = "EC2 instance types for the PostgreSQL node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "employee_instance_types" {
  description = "EC2 instance types for the Employee Management node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_disk_size" {
  description = "Worker node root disk size in GiB"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags applied to resources"
  type        = map(string)
  default     = {}
}
