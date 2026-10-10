
# =============================================================================
# Employee Management - NGINX Ingress Controller Module
# =============================================================================
# Purpose:
#   1. Create the dedicated NGINX Ingress namespace.
#   2. Deploy NGINX Ingress Controller using the local Helm chart.
#   3. Keep chart configuration in charts/nginx-ingress/values.yaml.
#
# Local chart path:
#   Terraform-Practice/charts/nginx-ingress/
#
# Architecture:
#   Internet -> AWS Network Load Balancer -> NGINX Ingress
#             -> Employee Management Kubernetes Services
#
# Important:
#   Run "helm dependency build ./charts/nginx-ingress" from the
#   Terraform root directory before running Terraform plan/apply.
# =============================================================================


# =============================================================================
# NGINX INGRESS NAMESPACE
# =============================================================================

resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/part-of"    = var.project_name
      "environment"                  = var.environment
    }
  }
}


# =============================================================================
# NGINX INGRESS HELM RELEASE
# =============================================================================

resource "helm_release" "nginx_ingress" {
  name      = var.release_name
  namespace = kubernetes_namespace.nginx_ingress.metadata[0].name

  # Load the local wrapper chart from the Terraform root directory.
  chart = "${path.root}/charts/nginx-ingress"

  # The namespace is managed separately by Terraform.
  create_namespace = false

  # Wait for Kubernetes resources to become ready.
  wait    = true
  timeout = var.helm_timeout

  # Roll back a failed installation or upgrade.
  atomic = true

  # Clean up resources created by an unsuccessful installation.
  cleanup_on_fail = true

  depends_on = [
    kubernetes_namespace.nginx_ingress
  ]
}
