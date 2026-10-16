
variable "namespace" {
  description = "Kubernetes namespace for NGINX Ingress"
  type        = string
  default     = "ingress-nginx"
}

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "ingress-nginx"
}

variable "chart_version" {
  description = "Pinned ingress-nginx Helm chart version"
  type        = string
}

variable "service_type" {
  description = "Kubernetes Service type"
  type        = string
  default     = "LoadBalancer"
}

variable "scheme" {
  description = "NLB scheme"
  type        = string
  default     = "internet-facing"

  validation {
    condition     = contains(["internet-facing", "internal"], var.scheme)
    error_message = "scheme must be internet-facing or internal."
  }
}
