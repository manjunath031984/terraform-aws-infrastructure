# =============================================================================
# Employee Management - NGINX Ingress Controller Outputs
# =============================================================================


# =============================================================================
# NAMESPACE
# =============================================================================

output "namespace" {
  description = "Kubernetes namespace where NGINX Ingress Controller is deployed."

  value = kubernetes_namespace.nginx_ingress.metadata[0].name
}


# =============================================================================
# HELM RELEASE
# =============================================================================

output "release_name" {
  description = "Helm release name of the NGINX Ingress Controller."

  value = helm_release.nginx_ingress.name
}


output "release_status" {
  description = "Current status of the NGINX Ingress Controller Helm release."

  value = helm_release.nginx_ingress.status
}


output "chart_version" {
  description = "Installed NGINX Ingress Controller Helm chart version."

  value = helm_release.nginx_ingress.version
}


# =============================================================================
# INGRESS CLASS
# =============================================================================

output "ingress_class_name" {
  description = "Kubernetes IngressClass name used by NGINX."

  value = var.ingress_class_name
}