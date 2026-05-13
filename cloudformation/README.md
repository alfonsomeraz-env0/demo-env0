# CloudFormation Demo

Demonstrates deploying AWS infrastructure using CloudFormation (instead of Terraform), managed through env0. Shows that env0 is IaC-tool agnostic.

## What This Creates

- S3 bucket via a CloudFormation stack
- Stack parameters for bucket name and environment tag
- Stack outputs exposed after deployment

## env0 Setup

| Field | Value |
|---|---|
| **IaC Type** | CloudFormation |
| **Working Directory** | `cloudformation` |
| **Stack Name** | Set via `STACK_NAME` variable |

## Variables

| Name | Type | Description |
|---|---|---|
| `STACK_NAME` | string | CloudFormation stack name (used in env0.yaml post-deploy) |
| `AWS_DEFAULT_REGION` | string | AWS region for the stack |
| `BucketName` | string | CloudFormation parameter — S3 bucket name |
| `Environment` | string | CloudFormation parameter — environment tag |

## How to Run

1. Create a new environment in env0 with **IaC Type: CloudFormation**
2. Point to `cloudformation/template.yaml`
3. Set `STACK_NAME` and CloudFormation parameters
4. Deploy — env0 creates the stack and the post-deploy step prints all stack outputs in a table

## Post-Deploy Output

After a successful deploy, the `env0.yaml` runs:

```bash
aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs" \
  --output table
```

This prints the bucket name and ARN directly in the env0 deployment log.

## Stack Outputs

| Output Key | Description |
|---|---|
| `BucketName` | Name of the created S3 bucket |
| `BucketArn` | ARN of the created S3 bucket |

## Resources Created

```
AWS::S3::Bucket
```
