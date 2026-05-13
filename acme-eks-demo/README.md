# ACME EKS Demo — Multi-Stage Workflow

Demonstrates an env0 workflow for deploying a Kubernetes platform in two stages: infrastructure first, then applications. Modeled after a realistic enterprise deployment pattern.

## Stages

```
infra ──► [approval required] ──► apps
```

| Stage | Template | Depends On | Approval | Description |
|---|---|---|---|---|
| `infra` | `acme-financial-eks-infra` | — | No | EKS cluster + VPC + node groups |
| `apps` | `acme-financial-eks-apps` | `infra` | **Yes** | Kubernetes workloads + Helm charts |

## Why Approval on Apps?

The apps stage requires manual approval because deploying workloads to a fresh cluster should be a deliberate, human-gated step. This pattern is common in regulated environments (financial services, healthcare) where infrastructure and application changes have separate approval chains.

## env0 Setup

1. Create a **Workflow Template** in env0
2. Point to `acme-eks-demo/env0.workflow.yaml`
3. Ensure these templates exist in your env0 organization:
   - `acme-financial-eks-infra` — EKS infrastructure template
   - `acme-financial-eks-apps` — Kubernetes applications template
4. Deploy the workflow

> **Note:** The EKS infrastructure and application templates are separate repositories/configurations registered in env0. This `env0.workflow.yaml` is the orchestration layer that connects them.

## Destroy Strategy

```yaml
settings:
  environmentRemovalStrategy: destroy
```

Applications are destroyed before the EKS cluster to avoid orphaned Kubernetes resources blocking cluster deletion.

## Use Cases

This pattern applies to any two-tier deployment where:
- Layer 1 creates platform infrastructure (EKS, RDS, networking)
- Layer 2 deploys workloads that depend on that platform
- A human needs to verify layer 1 before layer 2 proceeds
