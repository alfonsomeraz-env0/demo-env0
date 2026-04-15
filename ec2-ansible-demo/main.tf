provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  key_name = var.key_name

  tags = {
    Name = "env0-demo"
  }
}

resource "null_resource" "trigger_ansible" {
  depends_on = [aws_instance.demo]

  provisioner "local-exec" {
    command = <<EOT
      curl -s \
        -H "Authorization: Bearer ${var.semaphore_token}" \
        -H "Content-Type: application/json" \
        -X POST \
        -d '{"template_id": ${var.semaphore_template_id}, "environment": "{\"target_host\": \"${aws_instance.demo.public_ip}\"}" }' \
        "${var.semaphore_url}/api/project/${var.semaphore_project_id}/tasks"
    EOT
  }
}
