# Terraform Full-Stack Demo

Demonstrates a complete multi-module Terraform deployment — VPC, security groups, IAM, EC2, and S3 — composed into a single root module and managed through env0.

## Architecture

```
terraform/
├── main.tf              # Root module — composes all child modules
├── variables.tf
├── outputs.tf
└── modules/
    ├── vpc/             # VPC + public subnet + IGW
    ├── security_groups/ # EC2 security group (SSH/HTTP/HTTPS)
    ├── iam/             # EC2 instance role + profile
    ├── ec2/             # EC2 instance (AL2023, IMDSv2, encrypted EBS)
    └── s3/              # S3 bucket with versioning + lifecycle
```

## Dependency Graph

```
vpc
 ├── security_groups
 └── iam
      └── ec2 (depends on vpc + security_groups + iam)

s3 (independent)
```

## env0 Setup

| Field | Value |
|---|---|
| **IaC Type** | Terraform |
| **Terraform Version** | >= 1.0 |
| **Working Directory** | `terraform` |

## Variables

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `environment` | string | `dev` | No | Environment name |
| `aws_region` | string | `us-east-1` | No | AWS region |
| `availability_zone_suffix` | string | `a` | No | AZ suffix (a, b, c) |
| `vpc_cidr` | string | `10.0.0.0/16` | No | VPC CIDR block |
| `public_subnet_cidr` | string | `10.0.1.0/24` | No | Public subnet CIDR |
| `allowed_ssh_cidrs` | list(string) | `["0.0.0.0/0"]` | No | CIDRs allowed for SSH |
| `instance_type` | string | `t3.micro` | No | EC2 instance type |
| `instance_name` | string | `demo-instance` | No | EC2 name tag |
| `root_volume_size` | number | `20` | No | Root volume size in GB |
| `s3_bucket_name` | string | — | **Yes** | S3 bucket name (globally unique) |
| `s3_version_retention_days` | number | `30` | No | Days to retain old object versions |
| `s3_enable_lifecycle_archival` | bool | `false` | No | Enable auto-archival to STANDARD_IA |
| `s3_archive_transition_days` | number | `90` | No | Days before archiving objects |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | VPC ID |
| `instance_id` | EC2 instance ID |
| `instance_public_ip` | EC2 public IP |
| `instance_private_ip` | EC2 private IP |
| `s3_bucket_id` | S3 bucket name |
| `s3_bucket_arn` | S3 bucket ARN |

## Multi-Environment Usage

Use env0's environment-level variable overrides to deploy the same template to dev, staging, and prod with different values:

| Variable | dev | staging | prod |
|---|---|---|---|
| `environment` | `dev` | `staging` | `prod` |
| `instance_type` | `t3.micro` | `t3.small` | `t3.medium` |
| `allowed_ssh_cidrs` | `["0.0.0.0/0"]` | `["10.0.0.0/8"]` | `["10.0.0.0/8"]` |

## How to Run

1. Create a new environment in env0 using this template
2. Set `s3_bucket_name` to a globally unique value
3. Deploy — all 5 modules deploy with proper dependency ordering

## Resources Created

```
aws_vpc + aws_subnet + aws_internet_gateway + aws_route_table
aws_security_group
aws_iam_role + aws_iam_instance_profile + aws_iam_role_policy
aws_instance
aws_s3_bucket + aws_s3_bucket_versioning
```
