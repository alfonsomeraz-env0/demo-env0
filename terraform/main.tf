terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = var.environment
      Project     = "demo-env0"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidr    = var.public_subnet_cidr
  availability_zone     = "${var.aws_region}${var.availability_zone_suffix}"
}

module "security_groups" {
  source = "./modules/security_groups"

  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs
}

module "iam" {
  source = "./modules/iam"

  environment       = var.environment
  s3_bucket_name    = module.s3.bucket_id
}

module "ec2" {
  source = "./modules/ec2"

  environment                 = var.environment
  instance_name               = var.instance_name
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnet_id
  security_group_ids          = [module.security_groups.ec2_security_group_id]
  iam_instance_profile_name   = module.iam.ec2_instance_profile_name
  root_volume_size            = var.root_volume_size

  depends_on = [module.vpc, module.security_groups, module.iam]
}

module "s3" {
  source = "./modules/s3"

  environment                = var.environment
  bucket_name                = var.s3_bucket_name
  version_retention_days     = var.s3_version_retention_days
  enable_lifecycle_archival  = var.s3_enable_lifecycle_archival
  archive_transition_days    = var.s3_archive_transition_days
}
