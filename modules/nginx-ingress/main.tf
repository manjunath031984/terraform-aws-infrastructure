
# =============================================================================
# Employee Management - NGINX Ingress Controller Module
# =============================================================================
# Deploys the NGINX Ingress Controller using the official Helm chart.
#
# Architecture:
#
# Internet
#    |
#    v
# AWS Network Load Balancer
#    |
#    v
# NGINX Ingress Controller
#    |
#    v
# Kubernetes Services
#
# The controller is deployed into the dedicated ingress-nginx namespace.
# NGINX runs on the Employee Management application worker node.
# No dedicated IAM role is created by this module.
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
      "environment"                  = var.environment
    }
  }
}


# =============================================================================
# NGINX INGRESS HELM RELEASE
# =============================================================================

resource "helm_release" "nginx_ingress" {
  name       = var.release_name
  repository = "https://kubernetes.github.io/ingress-nginx/"
  chart      = "ingress-nginx"
  version    = "4.13.0"

  namespace        = kubernetes_namespace.nginx_ingress.metadata[0].name
  create_namespace = false

  # ===========================================================================
  # HELM VALUES
  # Helm provider 3.x uses a list of objects for the set argument.
  # ===========================================================================

  set = [
    # -------------------------------------------------------------------------
    # NGINX CONTROLLER
    # -------------------------------------------------------------------------

    {
      name  = "controller.replicaCount"
      value = tostring(var.replica_count)
    },
    {
      name  = "controller.ingressClassResource.name"
      value = var.ingress_class_name
    },
    {
      name  = "controller.ingressClassResource.enabled"
      value = "true"
    },
    {
      name  = "controller.ingressClassResource.default"
      value = tostring(var.ingress_class_default)
    },

    # -------------------------------------------------------------------------
    # SERVICE
    # -------------------------------------------------------------------------

    {
      name  = "controller.service.type"
      value = "LoadBalancer"
    },

    # -------------------------------------------------------------------------
    # AWS NETWORK LOAD BALANCER
    # -------------------------------------------------------------------------

    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "external"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
      value = "instance"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
      value = var.load_balancer_scheme
    },

    # -------------------------------------------------------------------------
    # EXTERNAL TRAFFIC POLICY
    # -------------------------------------------------------------------------

    {
      name  = "controller.service.externalTrafficPolicy"
      value = var.external_traffic_policy
    },

    # -------------------------------------------------------------------------
    # RESOURCE REQUESTS
    # -------------------------------------------------------------------------

    {
      name  = "controller.resources.requests.cpu"
      value = var.cpu_request
    },
    {
      name  = "controller.resources.requests.memory"
      value = var.memory_request
    },

    # -------------------------------------------------------------------------
    # RESOURCE LIMITS
    # -------------------------------------------------------------------------

    {
      name  = "controller.resources.limits.cpu"
      value = var.cpu_limit
    },
    {
      name  = "controller.resources.limits.memory"
      value = var.memory_limit
    },

    # -------------------------------------------------------------------------
    # NODE PLACEMENT
    # Application node label: workload=application
    # Application node taint: workload=application:NoSchedule
    # -------------------------------------------------------------------------

    {
      name  = "controller.nodeSelector.workload"
      value = "application"
    },
    {
      name  = "controller.tolerations[0].key"
      value = "workload"
    },
    {
      name  = "controller.tolerations[0].operator"
      value = "Equal"
    },
    {
      name  = "controller.tolerations[0].value"
      value = "application"
    },
    {
      name  = "controller.tolerations[0].effect"
      value = "NoSchedule"
    }
  ]

  # ===========================================================================
  # HELM RELEASE BEHAVIOR
  # ===========================================================================

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = var.helm_timeout

  depends_on = [
    kubernetes_namespace.nginx_ingress
  ]
}
