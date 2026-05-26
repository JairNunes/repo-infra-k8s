output "service_name" {
  value = kubernetes_service.app.metadata[0].name
}

output "namespace" {
  value = kubernetes_namespace.app.metadata[0].name
}

output "service_load_balancer_hostname" {
  value = try(kubernetes_service.app.status[0].load_balancer[0].ingress[0].hostname, "")
}
