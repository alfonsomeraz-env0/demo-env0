output "web_instance_ips" {
  description = "Public IPs of web tier instances"
  value       = aws_instance.web[*].public_ip
}

output "app_instance_ips" {
  description = "Public IPs of app tier instances"
  value       = aws_instance.app[*].public_ip
}

output "web_url" {
  description = "Load balancer URL"
  value       = "http://${aws_instance.web[0].public_ip}"
}

output "ssm_bucket_name" {
  description = "S3 bucket used by Ansible for SSM file transfers"
  value       = aws_s3_bucket.ansible_tmp.bucket
}
