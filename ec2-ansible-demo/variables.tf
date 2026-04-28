variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  default     = "ami-0ea3c35c5c3284d82"  # Ubuntu 22.04 LTS in us-east-2
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}