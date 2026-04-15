provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "demo_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "env0-demo-instance"
  }

  provisioner "local-exec" {
    command = <<EOT
      curl -s -k -u "${var.awx_user}:${var.awx_password}" \
        -H "Content-Type: application/json" \
        -X POST \
        -d '{"extra_vars": {"target_host": "${self.public_ip}"}}' \
        "${var.awx_url}/api/v2/job_templates/${var.awx_job_template_id}/launch/"
    EOT
  }
}
