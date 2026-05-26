variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.29"
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "node_instance_type" {
  description = "Tipo de instância dos worker nodes"
  type        = string
  default     = "t3.medium"
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
