output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  value = module.eks.ecr_repository_url
}

output "namespace" {
  value = module.k8s_resources.namespace
}

output "service_load_balancer_hostname" {
  value = module.k8s_resources.service_load_balancer_hostname
}

output "kubeconfig_command" {
  description = "Comando pra atualizar o kubeconfig local"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}
