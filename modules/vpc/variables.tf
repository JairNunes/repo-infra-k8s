variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name (used in tags)"
  type        = string
}
