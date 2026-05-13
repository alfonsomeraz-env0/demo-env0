# Security Group Demo

Demonstrates creating a configurable AWS security group with dynamic ingress rules using Terraform, managed through env0.

## What This Creates

- Security group with fully configurable ingress rules (defined as a variable)
- Unrestricted egress (standard outbound-all rule)

## env0 Setup

| Field | Value |
|---|---|
| **IaC Type** | Terraform |
| **Terraform Version** | >= 1.0 |
| **Working Directory** | `security_group` |

## Variables

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `aws_region` | string | `us-east-1` | No | AWS region |
| `environment` | string | `dev` | No | Environment name |
| `name` | string | — | **Yes** | Name suffix for the security group |
| `description` | string | `Managed by Terraform` | No | SG description |
| `vpc_id` | string | — | **Yes** | VPC ID to create the SG in |
| `ingress_rules` | list(object) | SSH+HTTP+HTTPS | No | List of ingress rules |

### `ingress_rules` Object Schema

```hcl
{
  from_port   = number
  to_port     = number
  protocol    = string       # "tcp", "udp", "-1"
  cidr_blocks = list(string)
  description = string       # optional
}
```

## Default Ingress Rules

| Port | Protocol | Source | Purpose |
|---|---|---|---|
| 22 | TCP | 0.0.0.0/0 | SSH |
| 80 | TCP | 0.0.0.0/0 | HTTP |
| 443 | TCP | 0.0.0.0/0 | HTTPS |

## Outputs

| Name | Description |
|---|---|
| `security_group_id` | ID of the created security group |

## How to Run

1. Create a new environment in env0 using this template
2. Set `vpc_id` (use the output from the `vpc` demo or an existing VPC)
3. Set `name` (e.g. `web-sg`)
4. Optionally override `ingress_rules` to restrict or expand access
5. Deploy

## Resources Created

```
aws_security_group (with dynamic ingress rules)
```
