terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "web_sg" {
  name   = "env0-ansible-demo-web-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "env0-ansible-demo-web-sg"
    ManagedBy = "env0"
  }
}

# App tier only accepts traffic on 8080 from the web tier SG
resource "aws_security_group" "app_sg" {
  name   = "env0-ansible-demo-app-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description     = "App port from web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "env0-ansible-demo-app-sg"
    ManagedBy = "env0"
  }
}

resource "aws_instance" "web" {
  count                       = var.web_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  tags = {
    Name      = "env0-ansible-demo-web-${count.index + 1}"
    Role      = "web"
    Project   = "env0-ansible-demo"
    ManagedBy = "env0"
  }
}

resource "aws_instance" "app" {
  count                       = var.app_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.app_sg.id]

  tags = {
    Name      = "env0-ansible-demo-app-${count.index + 1}"
    Role      = "app"
    Project   = "env0-ansible-demo"
    ManagedBy = "env0"
  }
}
