variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "oficina-mecanica"
}

variable "cluster_name" {
  type    = string
  default = "oficina-mecanica-eks"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "namespace" {
  type    = string
  default = "auto-repair-shop"
}

variable "database_url" {
  type      = string
  sensitive = true
}

variable "jwt_secret" {
  type      = string
  sensitive = true
}

variable "admin_email" {
  type    = string
  default = "admin@oficina-mecanica.app"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "new_relic_license_key" {
  type      = string
  sensitive = true
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "notify_lambda_url" {
  type    = string
  default = ""
}
