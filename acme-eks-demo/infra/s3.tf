resource "aws_s3_bucket" "eks_logs" {
  bucket = "acme-financial-eks-logs-${var.aws_account_id}"

  tags = {
    Name = "acme-eks-logs"
    App  = "payments"
  }
}

resource "aws_s3_bucket_versioning" "eks_logs" {
  bucket = aws_s3_bucket.eks_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "eks_logs" {
  bucket = aws_s3_bucket.eks_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
