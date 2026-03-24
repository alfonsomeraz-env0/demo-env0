variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name (must be globally unique)"
  type        = string
}

variable "version_retention_days" {
  description = "Number of days to retain old object versions"
  type        = number
  default     = 30
}

variable "enable_lifecycle_archival" {
  description = "Enable automatic archival of old objects to Infrequent Access"
  type        = bool
  default     = false
}

variable "archive_transition_days" {
  description = "Number of days before archiving objects to STANDARD_IA"
  type        = number
  default     = 90
}
