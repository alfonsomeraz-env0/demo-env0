variable "eks_cluster_name" {
  description = "EKS cluster name - output from acme-eks-infra environment"
  type        = string
  default     = "acme-financial-eks"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}
