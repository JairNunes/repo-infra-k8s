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

variable "image_repository" {
  description = "ECR repository URL"
  type        = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "notify_lambda_url" {
  description = "Lambda /notify/status-change endpoint URL"
  type        = string
  default     = ""
}
