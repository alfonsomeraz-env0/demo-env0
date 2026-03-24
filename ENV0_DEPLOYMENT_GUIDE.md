# Env0 Deployment Guide

This guide explains how to use this repository with the **env0 platform** for automated infrastructure deployments, approvals, and governance.

## What is Env0?

Env0 is an Infrastructure-as-Code (IaC) platform that provides:

- **Git-driven deployments**: Infrastructure changes flow through git workflows
- **Governance & Approvals**: Built-in approval gates and policy enforcement
- **Cost Management**: Real-time cost estimation and tracking
- **Environment Management**: Simplified multi-environment orchestration
- **Team Collaboration**: Unified interface for DevOps and developers
- **Workflow Automation**: Complex, multi-stage deployments with dependencies

## Env0 Setup

### 1. Connect Your Repository

1. Log in to env0 account
2. Click **"New Project"** → **"Connect Repository"**
3. Select **GitHub/GitLab/Bitbucket** and authorize
4. Select this repository: `demo-env0`
5. Choose **Terraform** as IaC tool
6. Set working directory: `terraform`

### 2. Configure AWS Credentials

In env0 Project Settings:

1. **Cloud Credentials** → **AWS**
2. Select authentication method:
   - **IAM User** (Access Key ID + Secret Key)
   - **IAM Role** (AssumeRole approach - recommended)
3. Save and verify connection

### 3. Create Environments

For each environment (dev, staging, prod):

1. **Environments** → **New Environment**
2. Configure:
   ```
   Name: demo-dev (or staging/prod)
   Working Directory: terraform/environments/dev
   Terraform Version: 1.5+
   ```
3. Set environment variables:
   ```
   TF_VAR_environment=dev
   TF_VAR_aws_region=us-east-1
   ```
4. Link to terraform variables file:
   ```
   Terraform vars file: terraform/environments/dev/terraform.auto.tfvars
   ```

## Deployment Workflows

### Using Predefined Workflows

This repository includes three pre-configured workflows:

#### 1. Foundation Deployment (VPC Only)

For deploying just the network infrastructure:

```bash
env0 workflows deploy vpc-deployment.yaml
  --environment dev
  --approval-required true
```

**Benefits**:
- Fast deployment for testing
- Can be run independently
- Foundation for all other resources

#### 2. Complete Stack Deployment

Deploy all resources with automatic dependency management:

```bash
env0 workflows deploy complete-deployment.yaml \
  --environment staging \
  --auto-approve false
```

**Workflow Stages**:
1. **Foundation Phase** (Parallel): VPC + Security Groups
2. **Storage Phase** (After Foundation): S3 Bucket
3. **Compute Phase** (After Storage): EC2 + IAM
4. **Apply Phase** (Sequential): Apply all changes in order

**Features**:
- Intelligent dependency resolution
- Parallel planning, sequential apply
- Automatic rollback on failure
- Email/Slack notifications

#### 3. Environment Destruction

Safely tear down infrastructure:

```bash
env0 workflows deploy destroy-environment.yaml \
  --environment staging \
  --require-approval true
```

**Safety Features**:
- Reverses dependency order
- Optional approval gates
- Prevents accidental deletion
- Audit trail logging

## Manual Deployments

### Single Resource Deployment

To deploy only specific modules:

```bash
# Deploy just EC2 (assumes dependencies exist)
env0 deploy \
  --environment dev \
  --target module.ec2 \
  --approve

# Deploy VPC and Security Groups
env0 deploy \
  --environment staging \
  --target module.vpc \
  --target module.security_groups
```

### Promoting Between Environments

```bash
# Plan in staging
env0 deploy \
  --environment staging \
  --plan-only

# After approval, deploy to production
env0 deploy \
  --environment prod \
  --approve \
  --parallel-module-apply
```

## Approval & Governance

### Setting Approval Policies

In env0 Console:

1. **Policies** → **Approval Requirements**
2. Configure by environment:

```
Development:
  - Requires 1 approval for changes > $100/month

Staging:
  - Requires 2 approvals (DevOps + Product)
  - Changes > $50/month require C-level review

Production:
  - Requires 3 approvals (DevOps + Security + C-level)
  - All changes require approval
  - Restricted deployment window (business hours)
```

### Cost Estimation

Before approval, Env0 shows:

- **Current Cost**: Existing infrastructure monthly spend
- **Estimated New Cost**: Post-deployment monthly spend
- **Cost Delta**: Monthly increase/decrease
- **Approval Required If**: Delta exceeds threshold

Example:
```
Current: $42/month
Proposed: $89/month
Delta: +$47/month ✓ Within threshold - auto-approve

Current: $150/month
Proposed: $450/month
Delta: +$300/month ⚠️ REQUIRES APPROVAL
```

## Environment Variables & Secrets

### Managing Sensitive Data

**Option 1: Env0 Secrets Manager**

1. **Project Settings** → **Secrets**
2. Add:
   ```
   SSH_KEY (file)
   DATABASE_PASSWORD (string)
   API_TOKEN (string)
   ```
3. Reference in workflows:
   ```bash
   export SSH_KEY=${{ secrets.SSH_KEY }}
   export DB_PASS=${{ secrets.DATABASE_PASSWORD }}
   ```

**Option 2: AWS Secrets Manager**

Store sensitive values in AWS and reference from Terraform:

```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "demo-env0/db-password"
}
```

### Environment-Specific Variables

Override variables per environment:

**Development** (`terraform/environments/dev/terraform.auto.tfvars`):
```hcl
instance_type = "t3.micro"
allowed_ssh_cidrs = ["0.0.0.0/0"]  # Open for development
```

**Production** (`terraform/environments/prod/terraform.auto.tfvars`):
```hcl
instance_type = "t3.medium"
allowed_ssh_cidrs = ["10.0.0.0/8"]  # Restricted access
```

## Monitoring & Notifications

### Configure Notifications

In **Project Settings** → **Notifications**:

**Email Notifications**:
```
- Deployment started → DevOps team
- Deployment completed → All stakeholders
- Deployment failed → On-call engineer
```

**Slack Integration**:
```
1. Create Slack webhook: https://hooks.slack.com/services/XXX/YYY/ZZZ
2. In Env0: Notifications → Add Slack
3. Channel: #deployments
4. Events: deployment-started, deployment-success, deployment-failed
```

**PagerDuty Integration**:
- Link for critical failures in production
- Auto-trigger incident on deploy failure

### Monitoring Deployments

**Real-time logs**:
```bash
env0 logs deployment <deployment_id> --stream
```

**Deployment history**:
```bash
env0 deployments list --environment prod --limit 10
```

**Cost tracking**:
```bash
env0 costs report --project demo-env0 --month 2024-03
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy to Env0

on:
  push:
    branches: [main]
    paths: ['terraform/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Deploy via Env0
        env:
          ENV0_API_KEY: ${{ secrets.ENV0_API_KEY }}
          ENV0_API_SECRET: ${{ secrets.ENV0_API_SECRET }}
        run: |
          env0 deploy \
            --project-id ${{ secrets.ENV0_PROJECT_ID }} \
            --environment staging \
            --wait-for-completion

      - name: Notify Slack
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "Deployment to staging completed",
              "blocks": [{
                "type": "section",
                "text": {"type": "mrkdwn", "text": "${{ job.status }}"}
              }]
            }
```

## Rollback Procedures

### Automated Rollback

If deployment fails:

```bash
env0 deploy \
  --environment staging \
  --rollback \
  --previous-state
```

### Manual Rollback

Revert to previous version:

```bash
# List deployment history
env0 deployments history --environment prod

# Redeploy specific version
env0 deploy \
  --environment prod \
  --git-hash abc123def456
```

## Common Workflows

### Daily Development Cycle

1. **Push changes** to feature branch
2. Env0 **auto-deploys to dev** environment
3. **Review outputs** and test
4. Create **Pull Request** to main
5. Env0 **shows cost impact** in PR
6. **Approve & merge** to main
7. Env0 **automatically deploys to staging** on merge
8. After testing, **manually promote to production**

### Zero-Downtime Updates

For production deployments:

```yaml
# Workflow: canary-deployment.yaml
stages:
  - name: Plan
    steps:
      - terraform plan

  - name: Pre-deployment Checks
    steps:
      - run: health-check-service.sh

  - name: Deploy to 10% of Instances
    steps:
      - deploy-canary.sh
      - monitor-metrics.sh

  - name: Deploy to 100% (Requires Approval)
    approval: true
    steps:
      - deploy-all.sh
      - run-smoke-tests.sh
```

### Cost Optimization Review

Monthly cost analysis:

```bash
env0 costs report \
  --project demo-env0 \
  --month current \
  --group-by environment \
  --show-optimization-opportunities
```

## Troubleshooting

### Deployment Failed: "Variable Not Found"

**Problem**: Terraform can't find required variable

**Solution**:
1. Check `terraform.auto.tfvars` exists
2. Verify variable is listed in `variables.tf`
3. Confirm env0 environment variables are set:
   ```bash
   env0 env vars list --environment dev
   ```

### Approval Stuck

**Problem**: Deployment waiting for approval

**Solution**:
1. Check approval policies:
   ```bash
   env0 policies list
   ```
2. Request approval from correct stakeholder
3. Override (if authorized):
   ```bash
   env0 deploy <deployment_id> --force-approve
   ```

### Cost Estimate Too High

**Problem**: Estimated deployment cost exceeds budget

**Solution**:
1. Review resource sizing:
   ```hcl
   # Reduce instance type
   instance_type = "t3.small" # Instead of t3.medium
   ```
2. Disable non-critical features:
   ```hcl
   s3_enable_lifecycle_archival = false
   ```
3. Request exception in env0 with justification

### SSH Access After Deployment

**Problem**: Can't connect to EC2 instance

**Solution**:
1. Retrieve instance IP from env0:
   ```bash
   env0 outputs show --environment dev
   ```
2. Ensure SSH key is configured
3. Check security group allows SSH:
   ```bash
   env0 resources list --environment dev | grep security-group
   ```

## Best Practices for Env0

✅ **Do**:
- Use approval gates for production deployments
- Set cost estimation thresholds
- Monitor deployment logs in real-time
- Create environment-specific workflows
- Document breaking changes in commit messages
- Test in dev/staging before production
- Use Slack notifications for team awareness
- Regular cost audits and optimization

❌ **Don't**:
- Approve deployments without reviewing plan
- Bypass approval gates without authorization
- Deploy directly to production without staging first
- Use shared AWS credentials (use IAM roles)
- Ignore cost estimates - review every month
- Deploy during critical business hours without notice
- Forget to test rollback procedures

## Conclusion

The env0 platform transforms this Terraform repository into a fully-governed, collaborative IaC system. Teams can deploy confidently with built-in approvals, cost visibility, and automated workflows while maintaining control and compliance.

For more information, visit [env0 Documentation](https://docs.env0.com)
