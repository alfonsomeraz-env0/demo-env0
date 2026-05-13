terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "this" {
  name = "${var.environment}-${var.role_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = var.trusted_service
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-${var.role_name}"
    Environment = var.environment
  }
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0
  name  = "${var.environment}-${var.role_name}-profile"
  role  = aws_iam_role.this.name
}

resource "aws_iam_role_policy" "this" {
  count  = var.inline_policy != null ? 1 : 0
  name   = "${var.environment}-${var.role_name}-policy"
  role   = aws_iam_role.this.id
  policy = var.inline_policy
}
