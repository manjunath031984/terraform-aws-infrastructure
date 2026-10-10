
# =============================================================================
# Employee Management - NGINX Ingress Controller Outputs
# =============================================================================


# =============================================================================
# KUBERNETES NAMESPACE
# =============================================================================

output "namespace" {
  description = "Kubernetes namespace where NGINX Ingress Controller is deployed."

  value = kubernetes_namespace.nginx_ingress.metadata[0].name
}


# =============================================================================
# HELM RELEASE INFORMATION
# =============================================================================

output "release_name" {
  description = "Name of the NGINX Ingress Controller Helm release."

  value = helm_release.nginx_ingress.name
}


output "release_status" {
  description = "Current status of the NGINX Ingress Controller Helm release."

  value = helm_release.nginx_ingress.status
}


output "chart_version" {
  description = "Version of the local NGINX wrapper Helm chart."

  value = helm_release.nginx_ingress.version
}


# =============================================================================
# LOCAL CHART INFORMATION
# =============================================================================

output "chart_path" {
  description = "Local filesystem path of the NGINX Ingress Helm chart."

  value = "${path.root}/charts/nginx-ingress"
}
