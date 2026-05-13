# VPC + RDS Demo

Deploys a two-tier network with a VPC (public app tier + private database tier) and an RDS instance locked into the private tier, managed through env0.

## Architecture

```
VPC (10.0.0.0/16)
├── Public Subnets (×2, multi-AZ)     — app tier
│   └── Security Group: HTTP/HTTPS from internet
│
└── Private Subnets (×2, multi-AZ)    — database tier
    └── Security Group: DB port from app SG only
        └── RDS Instance (PostgreSQL or MySQL)
              DB Subnet Group spanning both private subnets
```

The RDS instance is:
- In **private subnets** — no public IP, no direct internet access
- Encrypted at rest (gp3 storage)
- Only reachable from resources in the app security group

## What This Creates

| Resource | Description |
|---|---|
| VPC | Custom CIDR, DNS enabled |
| 2 public subnets | Multi-AZ, for app-tier workloads |
| 2 private subnets | Multi-AZ, for RDS only |
| Internet Gateway + route table | Public internet for app tier |
| App security group | Inbound 80/443 from internet |
| RDS security group | DB port from app SG only — no direct internet |
| DB subnet group | Spans both private subnets for Multi-AZ support |
| RDS instance | PostgreSQL 16 (configurable), gp3, encrypted |

## env0 Setup

| Field | Value |
|---|---|
| **IaC Type** | Terraform |
| **Terraform Version** | >= 1.0 |
| **Working Directory** | `aws-core/vpc-rds` |

## Variables

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `aws_region` | string | `us-east-1` | No | AWS region |
| `environment` | string | `dev` | No | Environment name |
| `vpc_cidr` | string | `10.0.0.0/16` | No | VPC CIDR block |
| `db_engine` | string | `postgres` | No | `postgres` or `mysql` |
| `db_engine_version` | string | `16.3` | No | Engine version |
| `db_instance_class` | string | `db.t3.micro` | No | RDS instance class |
| `db_allocated_storage` | number | `20` | No | Storage in GiB |
| `db_name` | string | `appdb` | No | Database name |
| `db_username` | string | `dbadmin` | No | Master username |
| `db_password` | string | — | **Yes** | Master password — mark as **sensitive** in env0 |
| `db_port` | number | `5432` | No | `5432` for postgres, `3306` for mysql |
| `multi_az` | bool | `false` | No | Enable Multi-AZ (recommended for prod) |
| `backup_retention_days` | number | `7` | No | Automated backup retention |

> Set `db_password` as a **sensitive variable** in env0 so it is never shown in logs.

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | VPC ID |
| `public_subnet_ids` | App-tier subnet IDs |
| `private_subnet_ids` | Database-tier subnet IDs |
| `app_security_group_id` | App tier SG — attach to EC2/ECS tasks |
| `rds_security_group_id` | RDS SG ID |
| `db_endpoint` | Full endpoint with port |
| `db_host` | Hostname only |
| `db_port` | Port |
| `db_name` | Database name |
| `db_username` | Master username |

## Multi-Environment Configuration

| Variable | dev | staging | prod |
|---|---|---|---|
| `db_instance_class` | `db.t3.micro` | `db.t3.small` | `db.t3.medium` |
| `multi_az` | `false` | `false` | `true` |
| `backup_retention_days` | `1` | `7` | `30` |

## Connecting to the Database

The RDS instance is not publicly accessible. To connect:

1. **From an EC2 instance** in the public subnet with the app security group attached
2. **Via AWS Systems Manager Session Manager** (no SSH key required)
3. **Via a bastion host** in the public subnet

```bash
psql -h <db_host> -U dbadmin -d appdb
```

## Resources Created

```
aws_vpc
aws_subnet (×4: 2 public, 2 private)
aws_internet_gateway
aws_route_table + aws_route_table_association (public)
aws_security_group (app + rds)
aws_db_subnet_group
aws_db_instance
```
