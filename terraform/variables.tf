variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone_suffix" {
  description = "Availability zone suffix (a, b, c)"
  type        = string
  default     = "a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "demo-instance"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "s3_bucket_name" {
  description = "S3 bucket name (must be globally unique)"
  type        = string
}

variable "s3_version_retention_days" {
  description = "Number of days to retain old S3 object versions"
  type        = number
  default     = 30
}

variable "s3_enable_lifecycle_archival" {
  description = "Enable automatic archival of old objects to STANDARD_IA"
  type        = bool
  default     = false
}

variable "s3_archive_transition_days" {
  description = "Number of days before archiving S3 objects"
  type        = number
  default     = 90
}
