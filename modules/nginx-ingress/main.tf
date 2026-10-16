
resource "helm_release" "nginx_ingress" {
  name             = var.release_name
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  values = [
    yamlencode({
      controller = {
        replicaCount = 2

        service = {
          type = var.service_type

          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"          = var.scheme
          }
        }

        ingressClassResource = {
          enabled = true
          name    = "nginx"
          default = false
        }

        ingressClass = "nginx"
      }
    })
  ]

  wait    = true
  timeout = 600
}
