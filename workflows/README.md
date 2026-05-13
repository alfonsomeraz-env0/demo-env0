# Workflows — Full Stack Orchestration Demo

Demonstrates env0 Workflow Environments to deploy a complete AWS stack across four dependent environments with dependency management and approval gates.

## What This Orchestrates

```
vpc  ──────────────────────────────┐
  │                                │
  ├──► sg (security group)         │
  │         │                      │
  └──► db (S3 bucket) ─── [approval required]
                │                  │
                └──► ec2 (depends on db + sg)
```

## Stages

| Stage | Template | Depends On | Approval |
|---|---|---|---|
| `vpc` | `vpc` | — | No |
| `sg` | `security_group` | `vpc` | No |
| `db` | `s3_bucket` | `vpc` | **Yes** |
| `ec2` | `ec2` | `db`, `sg` | No |

## How env0 Workflows Work

An `env0.workflow.yaml` defines environments (stages) and their dependencies. env0 runs them in dependency order:

1. `vpc` deploys first (no dependencies)
2. `sg` and `db` deploy in parallel once VPC is up
3. `db` requires manual approval before proceeding
4. `ec2` deploys only after both `db` and `sg` are complete

On **destroy**, the order reverses automatically — EC2 is destroyed before its dependencies.

## env0 Setup

1. Create a **Workflow Template** in env0
2. Point to `workflows/env0.workflow.yaml`
3. Ensure each referenced template (`vpc`, `security_group`, `s3_bucket`, `ec2`) exists in your env0 organization
4. Deploy the workflow — env0 handles the sequencing

> **Note:** The template names in `env0.workflow.yaml` (`vpc`, `security_group`, `s3_bucket`, `ec2`) must match template names registered in your env0 organization. The corresponding Terraform code lives in the sibling folders of this repo.

## Destroy Strategy

```yaml
settings:
  environmentRemovalStrategy: destroy
```

When the workflow environment is removed, all child environments are destroyed in reverse dependency order.

## Related Demos

The individual components used in this workflow each have their own standalone demos:
- `vpc/` — VPC module
- `security_group/` — Security group module
- `s3_bucket/` — S3 bucket module
- `ec2/` — EC2 instance module
