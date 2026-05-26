output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.main.arn
}

output "node_role_arn" {
  value = aws_iam_role.node.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  value = aws_ecr_repository.app.name
}
