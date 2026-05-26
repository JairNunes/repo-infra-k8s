terraform {
  backend "s3" {
    bucket         = "oficina-mecanica-tfstate"
    key            = "infra-k8s/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "oficina-mecanica-tflock"
    encrypt        = true
  }
}
