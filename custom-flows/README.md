# Custom Flows Demo

Demonstrates env0 custom flows (`env0.yaml`) for pre-deploy validation and security scanning. Each subdirectory is a self-contained example showing a different pattern.

## Sub-Demos

| Folder | Description |
|---|---|
| [`pass/`](./pass/) | TFLint scan — deploys cleanly when no violations found |
| [`fail/`](./fail/) | TFLint scan — intentionally triggers a violation to show deployment blocking |
| [`multi-tool_scanning/`](./multi-tool_scanning/) | TFLint + tfsec + Checkov — three tools running in sequence before plan |
| [`combined_approval-custom/`](./combined_approval-custom/) | TFLint + tfsec + Checkov + manual approval gate after all scans pass |
| Root (`env0.yaml` + `main.tf`) | Simple TFLint pre-deploy gate |

---

## Patterns Demonstrated

### 1. Simple TFLint Gate (root)

Installs TFLint at deploy time, runs it, and blocks the deployment if any violations are found. The simplest version of a pre-deploy check.

**Working directory:** `custom-flows`

### 2. Pass / Fail Examples

`pass/` and `fail/` show the same TFLint flow with Terraform code that either passes or fails the scan — useful for live demos.

**Working directory:** `custom-flows/pass` or `custom-flows/fail`

### 3. Multi-Tool Scanning

Runs TFLint, tfsec, and Checkov in sequence before `terraform plan`. Any tool failure blocks the deployment.

| Tool | Checks |
|---|---|
| TFLint | Terraform code quality, invalid arguments, best practices |
| tfsec | Security misconfigurations (blocks on CRITICAL/HIGH) |
| Checkov | Compliance policy checks |

**Working directory:** `custom-flows/multi-tool_scanning`

### 4. Scans + Approval Gate

Same three-tool scan as above, but adds `requiresApproval: true` — so a human must approve after all scans pass before the deployment proceeds.

**Working directory:** `custom-flows/combined_approval-custom`

---

## env0 Setup

| Field | Value |
|---|---|
| **IaC Type** | Terraform |
| **Terraform Version** | >= 1.0 |
| **Working Directory** | See each sub-demo above |

## How Custom Flows Work

Steps in `env0.yaml` run inside the env0 deployment runner alongside Terraform. You can install any tool, run any script, and `exit 1` to fail the deployment at any point.

```yaml
deploy:
  steps:
    terraformPlan:
      before:
        - name: Run TFLint
          run: |
            curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
            tflint --init
            tflint --format json > results.json
            [ $(jq '.issues | length' results.json) -eq 0 ] || exit 1
```
