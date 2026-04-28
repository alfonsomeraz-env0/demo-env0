terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "acme" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "acme" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.acme.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.acme.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.acme.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.acme.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.acme.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.acme.token
  }
}
