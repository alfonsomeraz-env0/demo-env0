terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#######################################
# Providers
#######################################

provider "aws" {
  region = var.aws_region
}

# Secondary provider for replication (different region)
provider "aws" {
  alias  = "replica"
  region = var.replica_region
}

#######################################
# Data
#######################################

data "aws_caller_identity" "current" {}

#######################################
# S3 Bucket (Primary)
#######################################

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

#######################################
# Versioning (Required for replication)
#######################################

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

#######################################
# Public Access Block (CKV2_AWS_6)
#######################################

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#######################################
# KMS Key (CKV_AWS_7 + CKV2_AWS_64)
#######################################

resource "aws_kms_key" "s3" {
  description             = "KMS key for ${var.bucket_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.bucket_name}-kms"
    Environment = var.environment
  }
}

#######################################
# S3 Encryption (CKV_AWS_145)
#######################################

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}

#######################################
# Event Notifications (CKV2_AWS_62)
#######################################

resource "aws_sns_topic" "bucket_events" {
  name = "${var.bucket_name}-events"
}

resource "aws_s3_bucket_notification" "this" {
  bucket = aws_s3_bucket.this.id

  topic {
    topic_arn = aws_sns_topic.bucket_events.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

#######################################
# Replica Bucket (Secondary Region)
#######################################

resource "aws_s3_bucket" "replica" {
  provider = aws.replica
  bucket   = "${var.bucket_name}-replica"

  tags = {
    Name        = "${var.bucket_name}-replica"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  versioning_configuration {
    status = "Enabled"
  }
}

#######################################
# IAM Role for Replication
#######################################

resource "aws_iam_role" "replication" {
  name = "${var.bucket_name}-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "replication" {
  name = "${var.bucket_name}-replication-policy"
  role = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = [aws_s3_bucket.this.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = ["${aws_s3_bucket.this.arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = ["${aws_s3_bucket.replica.arn}/*"]
      }
    ]
  })
}

#######################################
# Replication Configuration (CKV_AWS_144)
#######################################

resource "aws_s3_bucket_replication_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica.arn
      storage_class = "STANDARD"
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.this,
    aws_s3_bucket_versioning.replica
  ]
}
