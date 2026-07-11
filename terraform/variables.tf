variable "aws_region" {
  description = "Regiao da AWS para o deploy dos recursos"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de execucao"
  type        = string
  default     = "production"
}

variable "cluster_name" {
  description = "Nome do cluster EKS da Solidary Tech"
  type        = string
  default     = "solidary-tech-eks"
}
