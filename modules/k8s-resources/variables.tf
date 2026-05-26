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
  type        = string
  description = "URL do ECR repository (vem do módulo eks)"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "notify_lambda_url" {
  type        = string
  description = "URL completa do endpoint Lambda /notify/status-change (vem do repo-lambda-auth)"
  default     = ""
}
