variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "web_count" {
  description = "Number of web tier (nginx) instances"
  default     = 1
}

variable "app_count" {
  description = "Number of app tier instances"
  default     = 2
}
