# IAM Role Demo

Demonstrates creating a reusable AWS IAM role with optional instance profile and inline policy using Terraform, managed through env0.

## What This Creates

- IAM role with a configurable assume-role trust policy
- Optional EC2 instance profile (for attaching the role to EC2 instances)
- Optional inline policy attached to the role

## env0 Setup

| Field | Value |
|---|---|
| **IaC Type** | Terraform |
| **Terraform Version** | >= 1.0 |
| **Working Directory** | `iam_role` |

## Variables

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `aws_region` | string | `us-east-1` | No | AWS region |
| `environment` | string | `dev` | No | Environment name |
| `role_name` | string | — | **Yes** | Name suffix for the IAM role |
| `trusted_service` | string | `ec2.amazonaws.com` | No | AWS service that can assume this role |
| `create_instance_profile` | bool | `false` | No | Whether to create an EC2 instance profile |
| `inline_policy` | string | `null` | No | JSON-encoded inline policy document |

## Example: EC2 Role with S3 Read Access

Set these variables in env0:

```
role_name               = "app-server"
trusted_service         = "ec2.amazonaws.com"
create_instance_profile = true
inline_policy           = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:ListBucket"],
    "Resource": "*"
  }]
}
EOF
```

## Outputs

| Name | Description |
|---|---|
| `role_arn` | ARN of the IAM role |
| `role_name` | Name of the IAM role |
| `instance_profile_name` | Name of the instance profile (if created) |

## How to Run

1. Create a new environment in env0 using this template
2. Set `role_name` and configure the trusted service
3. Optionally enable `create_instance_profile` for EC2 use cases
4. Deploy

## Resources Created

```
aws_iam_role
aws_iam_instance_profile  (conditional)
aws_iam_role_policy       (conditional)
```
