# EC2 + Ansible Demo

Demonstrates combining Terraform infrastructure provisioning with Ansible configuration management, orchestrated entirely through env0.

## What This Creates

- 2 Ubuntu EC2 instances (web tier + app tier) with a dynamically generated TLS key pair
- Security groups for HTTP (80), HTTPS (443), and SSH (22)
- Ansible configures Apache on the web instances and deploys a styled HTML landing page

## Architecture

```
env0 Deploy
  │
  ├── terraform init
  │     └── installs Ansible + boto3 via pip
  │
  ├── terraform apply
  │     ├── EC2 web instances
  │     ├── EC2 app instances
  │     └── TLS key pair
  │
  └── post-apply steps
        ├── extract SSH key from Terraform output
        ├── wait for EC2 initialization (~60s)
        ├── wait for SSH on all instances (up to 40 retries)
        ├── run Ansible playbook (site.yml)
        └── verify deployment via HTTP health check
```

## env0 Setup

| Field | Value |
|---|---|
| **IaC Type** | Terraform |
| **Terraform Version** | >= 1.0 |
| **Working Directory** | `ec2-ansible-demo` |

## Variables

| Name | Type | Description |
|---|---|---|
| `aws_region` | string | AWS region (default: `us-east-1`) |
| `environment` | string | Environment name (default: `dev`) |
| `vpc_id` | string | VPC ID to deploy into |
| `subnet_id` | string | Public subnet ID |
| `web_instance_count` | number | Number of web instances (default: `1`) |
| `app_instance_count` | number | Number of app instances (default: `1`) |

## Ansible Roles

- **appserver** — installs Apache, deploys `index.html` and `app.py` to the web instances

## How to Run

1. Create a new environment in env0 with IaC type **Terraform**
2. Set `vpc_id` and `subnet_id` for your target AWS account
3. Deploy — env0 handles Ansible installation and playbook execution automatically

## What Makes This Interesting

This demo shows that env0's `env0.yaml` custom flows can turn a standard Terraform deployment into a full configuration management pipeline — no separate CI/CD pipelines or Ansible Tower required.

## Resources Created

```
aws_instance (web × N, app × N)
aws_security_group
aws_key_pair (TLS, generated at deploy time)
```
