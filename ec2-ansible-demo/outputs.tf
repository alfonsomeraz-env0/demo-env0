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

output "private_key_pem" {
  description = "Private key for Ansible SSH access"
  value       = tls_private_key.ansible.private_key_openssh
  sensitive   = true
}
