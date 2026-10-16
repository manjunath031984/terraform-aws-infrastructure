
variable "cluster_name" {
  description = "Name of the existing EKS cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL from the EKS cluster"
  type        = string
}

variable "ebs_csi_role_name" {
  description = "IAM role name for the EBS CSI Driver"
  type        = string
  default     = "employee-management-ebs-csi-role"
}

variable "tags" {
  description = "Tags for IAM resources"
  type        = map(string)
  default     = {}
}
