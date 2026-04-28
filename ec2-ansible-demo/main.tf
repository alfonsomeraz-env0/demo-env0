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

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
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

# ── IAM: allow instances to register with SSM and access the staging bucket ──

resource "aws_iam_role" "ssm_role" {
  name = "env0-ansible-demo-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { ManagedBy = "env0" }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ssm_s3" {
  name = "env0-ansible-demo-ssm-s3"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
      Resource = [aws_s3_bucket.ansible_tmp.arn, "${aws_s3_bucket.ansible_tmp.arn}/*"]
    }]
  })
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "env0-ansible-demo-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# ── S3: staging bucket for Ansible file/template transfers over SSM ──

resource "aws_s3_bucket" "ansible_tmp" {
  bucket_prefix = "env0-ansible-demo-ssm-"
  force_destroy = true

  tags = { ManagedBy = "env0" }
}

resource "aws_s3_bucket_lifecycle_configuration" "ansible_tmp" {
  bucket = aws_s3_bucket.ansible_tmp.id

  rule {
    id     = "expire-tmp"
    status = "Enabled"
    filter {}
    expiration { days = 1 }
  }
}

# ── Security groups — no port 22, all Ansible traffic goes via SSM ──

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

# ── EC2 instances — no key_name, IAM profile enables SSM access ──

resource "aws_instance" "web" {
  count                       = var.web_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name      = "env0-ansible-demo-web-${count.index + 1}"
    Role      = "web"
    Project   = "env0-ansible-demo"
    ManagedBy = "env0"
  }
}

resource "aws_instance" "app" {
  count                       = var.app_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name      = "env0-ansible-demo-app-${count.index + 1}"
    Role      = "app"
    Project   = "env0-ansible-demo"
    ManagedBy = "env0"
  }
}
