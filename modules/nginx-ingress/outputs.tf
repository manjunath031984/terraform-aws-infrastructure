
output "namespace" {
  description = "Namespace running NGINX Ingress"
  value       = helm_release.nginx_ingress.namespace
}

output "release_name" {
  description = "NGINX Ingress Helm release"
  value       = helm_release.nginx_ingress.name
}
