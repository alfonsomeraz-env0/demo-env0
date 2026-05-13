# Terragrunt Workflow Demo

Demonstrates a two-stage env0 workflow that first provisions the Terragrunt remote state backend, then deploys the Terragrunt stack — ensuring the backend always exists before any module runs.

## Stages

```
bootstrap ──► terragrunt
```

| Stage | Template | Depends On | Description |
|---|---|---|---|
| `bootstrap` | `bootstrap-terragrunt-s3` | — | Creates S3 + DynamoDB for remote state |
| `terragrunt` | `terragrunt-deployment` | `bootstrap` | Deploys the Terragrunt stack |

## Why This Order Matters

Terragrunt requires an S3 bucket and DynamoDB table for remote state before it can initialize. If the backend doesn't exist, `terragrunt init` fails. This workflow solves that problem by making the bootstrap stage a hard dependency.

## env0 Setup

1. Create a **Workflow Template** in env0
2. Point to `terragrunt-workflow/env0.workflow.yaml`
3. Ensure these templates exist in your env0 organization:
   - `bootstrap-terragrunt-s3` → the `terragrunt-bootstrap/` folder
   - `terragrunt-deployment` → the `terragrunt/` folder
4. Deploy the workflow

## Destroy Strategy

```yaml
settings:
  environmentRemovalStrategy: destroy
```

On removal, the Terragrunt stack is destroyed first, then the state backend. This prevents orphaned state files.

## Related Demos

- `terragrunt-bootstrap/` — the bootstrap stage (S3 + DynamoDB)
- `terragrunt/` — the Terragrunt deployment stage
