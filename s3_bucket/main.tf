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

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Name        = "this-is-my-test-bucket-alfonso-1234"
    Environment = "dev"
    Test-Tag    = "This is a tag I added to show drift"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}
