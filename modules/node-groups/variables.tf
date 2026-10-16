
variable "cluster_name" {
  description = "Name of the existing EKS cluster"
  type        = string
}

variable "node_role_name" {
  description = "IAM role name for EKS worker nodes"
  type        = string
  default     = "employee-management-eks-node-role"
}

variable "private_subnet_ids" {
  description = "Two private subnet IDs, one in each Availability Zone"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) == 2
    error_message = "Exactly two private subnet IDs are required."
  }
}

variable "postgres_instance_types" {
  description = "EC2 instance types for the PostgreSQL node"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "employee_instance_types" {
  description = "EC2 instance types for the Employee Management node"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "disk_size" {
  description = "Worker node root volume size in GiB"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to node group resources"
  type        = map(string)
  default     = {}
}
