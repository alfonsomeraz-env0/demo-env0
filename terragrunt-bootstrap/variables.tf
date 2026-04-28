variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terragrunt remote state"
  default     = "demo-env0-terragrunt-state"
}

variable "dynamodb_table_name" {
  type    = string
  default = "demo-env0-terragrunt-lock"
}
