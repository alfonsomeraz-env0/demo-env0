# Custom Flows — TFLint Demo

Demonstrates using env0 custom flows (`env0.yaml`) to gate a Terraform deployment behind a linting check. If TFLint finds violations in the Terraform code, the deployment fails before any infrastructure is created.

## What This Shows

- Installing tools at deploy time using env0 custom flow steps
- Running TFLint as a pre-deploy validation step
- Blocking a deployment automatically when violations are detected

## How It Works

The `env0.yaml` `deploy.before` hook runs before Terraform init:

1. Downloads and installs TFLint
2. Runs `tflint --init` to download rule plugins
3. Runs `tflint --format json > tflint-results.json`
4. Counts issues — if any exist, prints them and exits with code 1
5. env0 marks the deployment as failed, no infrastructure is touched

## env0 Setup

| Field | Value |
|---|---|
| **IaC Type** | Terraform |
| **Terraform Version** | >= 1.0 |
| **Working Directory** | `custom_flows` |

## Sample Terraform Code

The `main.tf` in this folder contains intentional patterns for TFLint to evaluate. Deploy it to see a passing scan, or introduce a violation (e.g. an invalid instance type string) to see the deployment gate in action.

## Extending This Pattern

You can combine TFLint with other tools in the same custom flow:

```yaml
deploy:
  before:
    - name: Run TFLint
      run: |
        curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
        tflint --init && tflint --format json > results.json
        [ $(jq '.issues | length' results.json) -eq 0 ] || exit 1

    - name: Run Checkov
      run: |
        pip install checkov
        checkov -d . --quiet
```

## Files

| File | Purpose |
|---|---|
| `env0.yaml` | Custom flow with TFLint pre-deploy gate |
| `main.tf` | Sample Terraform code for TFLint to scan |
