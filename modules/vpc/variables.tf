variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "name_prefix" {
  description = "Prefixo dos recursos"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster EKS (usado em tags)"
  type        = string
}
