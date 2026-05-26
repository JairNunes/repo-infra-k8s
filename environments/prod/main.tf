terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "oficina-mecanica"
      Environment = "prod"
      ManagedBy   = "terraform"
      Repo        = "repo-infra-k8s"
    }
  }
}

data "aws_eks_cluster_auth" "main" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
  token                  = data.aws_eks_cluster_auth.main.token
}

module "vpc" {
  source = "../../modules/vpc"

  name_prefix  = var.name_prefix
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  node_instance_type = var.node_instance_type
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
  node_desired_size  = var.node_desired_size
}

module "k8s_resources" {
  source = "../../modules/k8s-resources"

  namespace             = var.namespace
  database_url          = var.database_url
  jwt_secret            = var.jwt_secret
  admin_email           = var.admin_email
  admin_password        = var.admin_password
  new_relic_license_key = var.new_relic_license_key
  image_repository      = module.eks.ecr_repository_url
  image_tag             = var.image_tag
  notify_lambda_url     = var.notify_lambda_url

  depends_on = [module.eks]
}
