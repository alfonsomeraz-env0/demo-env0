variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "role_name" {
  description = "Name suffix for the IAM role"
  type        = string
}

variable "trusted_service" {
  description = "AWS service principal that can assume this role (e.g. ec2.amazonaws.com)"
  type        = string
  default     = "ec2.amazonaws.com"
}

variable "create_instance_profile" {
  description = "Whether to create an EC2 instance profile for this role"
  type        = bool
  default     = false
}

variable "inline_policy" {
  description = "JSON-encoded inline policy to attach to the role (null = no policy)"
  type        = string
  default     = null
}
