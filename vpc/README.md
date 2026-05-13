# VPC Demo

Demonstrates creating a basic AWS VPC with a public subnet using Terraform, managed through env0.

## What This Creates

- VPC with configurable CIDR block
- Public subnet with auto-assigned public IPs
- Internet Gateway
- Public route table associated to the subnet

## env0 Setup

| Field | Value |
|---|---|
| **IaC Type** | Terraform |
| **Terraform Version** | >= 1.0 |
| **Working Directory** | `vpc` |

## Variables

| Name | Type | Default | Description |
|---|---|---|---|
| `aws_region` | string | `us-east-1` | AWS region |
| `environment` | string | `dev` | Environment name |
| `vpc_cidr` | string | `10.0.0.0/16` | CIDR block for the VPC |
| `public_subnet_cidr` | string | `10.0.1.0/24` | CIDR for the public subnet |
| `availability_zone_suffix` | string | `a` | AZ suffix (a, b, c) |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | ID of the created VPC |
| `public_subnet_id` | ID of the public subnet |
| `vpc_cidr` | CIDR block of the VPC |

These outputs are consumed by the `ec2`, `security_group`, and `terraform` demos when used in a workflow.

## How to Run

1. Create a new environment in env0 using this template
2. Adjust CIDR blocks if they conflict with your existing networking
3. Deploy — the VPC is ready to use by other demos

## Used By

- `multi-tier-workflow/` — this is the foundation layer in the full-stack workflow
- `terraform/` — the root module includes this as a child module

## Resources Created

```
aws_vpc
aws_subnet (public)
aws_internet_gateway
aws_route_table
aws_route_table_association
```
