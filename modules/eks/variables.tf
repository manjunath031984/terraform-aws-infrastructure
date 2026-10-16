
variable "cluster_name" {
  description = "Name of the Amazon EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version supported by EKS in the selected region"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for EKS control-plane networking"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least two subnets for EKS networking."
  }
}

variable "endpoint_private_access" {
  description = "Enable private Kubernetes API endpoint access"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public Kubernetes API endpoint access"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR ranges allowed to access the public Kubernetes API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to EKS resources"
  type        = map(string)
  default     = {}
}
