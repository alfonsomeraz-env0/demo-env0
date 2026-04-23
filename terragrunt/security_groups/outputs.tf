output "ec2_security_group_id" {
  description = "Security group ID for EC2 instances"
  value       = aws_security_group.ec2.id
}

output "s3_access_security_group_id" {
  description = "Security group ID for S3 access"
  value       = aws_security_group.s3_access.id
}
