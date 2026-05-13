# Terragrunt Demo

Demonstrates using Terragrunt with env0 for DRY infrastructure configuration. The root `terragrunt.hcl` dynamically generates provider and version files, eliminating boilerplate across multiple modules.

## What This Shows

- Root `terragrunt.hcl` that generates `provider.tf` and `versions.tf` at runtime
- Default AWS tags applied across all resources (`Environment`, `Project`, `ManagedBy`)
- How env0 handles Terragrunt as the IaC type

## env0 Setup

| Field | Value |
|---|---|
| **IaC Type** | Terragrunt |
| **Terraform Version** | >= 1.0 |
| **Terragrunt Version** | >= 0.50 |
| **Working Directory** | `terragrunt` |

## What `terragrunt.hcl` Generates

**`provider.tf`**
```hcl
provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "demo-env0"
      ManagedBy   = "Terragrunt"
    }
  }
}
```

**`versions.tf`**
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

These files are generated into the module directory at `terragrunt init` time and do not need to be committed.

## How to Run

1. Create a new environment in env0 with **IaC Type: Terragrunt**
2. Set the working directory to `terragrunt`
3. Deploy — Terragrunt generates the provider config and initializes modules

## Related Demos

- **`terragrunt-bootstrap/`** — creates the S3 + DynamoDB backend that Terragrunt uses for remote state
- **`terragrunt-workflow/`** — orchestrates bootstrap + deployment in a two-stage env0 workflow
