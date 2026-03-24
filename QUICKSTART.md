# Quick Start Guide

## What's in This Repository?

This is a production-ready **Infrastructure-as-Code (IaC) demo** for the **env0 platform** with:

- ✅ **5 Modular Terraform Modules**: VPC, Security Groups, IAM, EC2, S3
- ✅ **3 Environments**: Dev, Staging, Production with distinct configurations
- ✅ **3 Deployment Workflows**: Foundation, Complete Stack, Destroy
- ✅ **Multi-Environment Strategy**: Parameterized for easy scaling
- ✅ **Production Security**: IMDSv2, encrypted volumes, public access blocking

## 5-Minute Setup

### 1. Clone & Initialize

```bash
cd terraform/environments/dev
terraform init
```

### 2. Review the Plan

```bash
terraform plan -var-file=terraform.auto.tfvars
```

You'll see:
- 1 VPC with public subnet
- 1 Security Group for EC2
- 1 S3 bucket with versioning
- 1 EC2 instance (t3.micro)
- 1 IAM role for S3 access

### 3. Deploy

```bash
terraform apply -var-file=terraform.auto.tfvars
```

### 4. Access Your Resources

```bash
# Get instance IP
terraform output instance_public_ip

# SSH into instance
ssh -i your-key.pem ec2-user@<IP>

# List S3 bucket
aws s3 ls <bucket-name>
```

### 5. Cleanup (Dev Only)

```bash
terraform destroy -var-file=terraform.auto.tfvars
```

---

## Repository Structure

### Documentation
- **README.md** - Full feature overview, best practices, deployment guide
- **ARCHITECTURE.md** - Dependency diagrams, network layout, IAM model
- **ENV0_DEPLOYMENT_GUIDE.md** - Complete env0 integration instructions
- **QUICKSTART.md** - This file

### Terraform Code
```
terraform/
├── main.tf                  # Root config combining all modules
├── variables.tf             # Shared variables (environment, AWS region, etc.)
├── outputs.tf               # Output values from all modules
├── modules/
│   ├── vpc/                 # VPC, subnet, internet gateway
│   ├── security_groups/     # Network security rules
│   ├── iam/                 # IAM roles and policies
│   ├── ec2/                 # EC2 instance with monitoring
│   └── s3/                  # S3 bucket with lifecycle policies
└── environments/
    ├── dev/                 # Development (t3.micro, open SSH)
    ├── staging/             # Staging (t3.small, private SSH)
    └── prod/                # Production (t3.medium, restricted)
```

### Workflows
```
workflows/
├── vpc-deployment.yaml           # Deploy just the foundation
├── complete-deployment.yaml      # Deploy all resources with dependency management
└── destroy-environment.yaml      # Tear down infrastructure safely
```

---

## Key Features

### 🏗️ Modular Design
Each component is independent:
- **VPC Module**: Network foundation (no dependencies)
- **S3 Module**: Storage (no dependencies)
- **Security Groups**: Network rules (depends on VPC)
- **IAM Module**: Permissions (depends on S3)
- **EC2 Module**: Compute (depends on all above)

### 🌍 Multi-Environment
Same code, different configs:

| Aspect | Dev | Staging | Prod |
|--------|-----|---------|------|
| Instance | t3.micro | t3.small | t3.medium |
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |
| SSH Access | Open (0.0.0.0/0) | Private | Private |
| S3 Retention | 7 days | 30 days | 90 days |
| S3 Archival | Off | On (60d) | On (30d) |

### 🔒 Security Built-In
- IMDSv2 enforced (prevents SSRF attacks)
- EBS volumes encrypted by default
- S3 public access blocked
- IAM roles instead of access keys
- Security groups with least privilege
- VPC isolation per environment

### 💰 Cost Optimized
- Dev: ~$5-10/month (free tier eligible)
- Staging: ~$15-25/month
- Prod: ~$25-40/month
- S3 lifecycle policies auto-archive old data

---

## Deploy to Different Environments

### Development
```bash
cd terraform/environments/dev
terraform init
terraform plan -var-file=terraform.auto.tfvars
terraform apply -var-file=terraform.auto.tfvars
```

### Staging
```bash
cd terraform/environments/staging
terraform init
terraform plan -var-file=terraform.auto.tfvars
terraform apply -var-file=terraform.auto.tfvars
```

### Production
```bash
cd terraform/environments/prod
terraform init
terraform plan -var-file=terraform.auto.tfvars
# Review plan carefully before applying
terraform apply -var-file=terraform.auto.tfvars
```

---

## Using with Env0

### 1. Connect Repository
1. Log into env0 console
2. Click **"New Project"** → **"Connect Repository"**
3. Select GitHub/GitLab/Bitbucket (authenticate)
4. Choose this repository
5. Set working directory: `terraform`

### 2. Configure Cloud Credentials
1. **Project Settings** → **Cloud Credentials** → **AWS**
2. Use IAM role or access keys
3. Verify connection

### 3. Create Environments
1. **Environments** → **New Environment**
2. Name: `demo-dev` (or staging/prod)
3. Working directory: `terraform/environments/dev`
4. Link `terraform.auto.tfvars` file

### 4. Deploy via Workflow
```bash
# List available workflows
env0 workflows list

# Deploy complete stack
env0 workflows run complete-deployment.yaml \
  --environment dev \
  --auto-approve false
```

### 5. Monitor
- View deployment logs in real-time
- Check cost estimates before approval
- Receive notifications (Slack, email)
- Track deployment history

---

## Common Tasks

### Get Outputs After Deployment
```bash
terraform output
```

### SSH into EC2 Instance
```bash
# Get IP
IP=$(terraform output -raw instance_public_ip)

# Connect
ssh -i /path/to/key.pem ec2-user@$IP
```

### Upload File to S3
```bash
BUCKET=$(terraform output -raw s3_bucket_id)
aws s3 cp myfile.txt s3://$BUCKET/
```

### Add EC2 Instance to Security Group
```bash
# Update terraform code, then:
terraform plan
terraform apply
```

### Increase Instance Size
Edit `terraform/environments/<env>/terraform.auto.tfvars`:
```hcl
instance_type = "t3.small"  # Was t3.micro
```

Then apply:
```bash
terraform plan -var-file=terraform.auto.tfvars
terraform apply -var-file=terraform.auto.tfvars
```

### Destroy Everything
```bash
# Development (safe)
cd terraform/environments/dev
terraform destroy -var-file=terraform.auto.tfvars

# Production (requires careful review)
cd terraform/environments/prod
terraform destroy -var-file=terraform.auto.tfvars
```

---

## Customization Examples

### Add RDS Database

1. Create module: `terraform/modules/rds/main.tf`
2. Reference in root: `terraform/main.tf`
3. Update environment configs with DB settings
4. Deploy normally

### Add Load Balancer

1. Create module: `terraform/modules/alb/main.tf`
2. Attach to EC2 security group
3. Configure target group
4. Deploy

### Enable VPC Flow Logs

Add to `terraform/modules/vpc/main.tf`:
```hcl
resource "aws_flow_log" "main" {
  iam_role_arn = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type = "ALL"
  vpc_id = aws_vpc.main.id
}
```

### Configure CloudWatch Alarms

Add to `terraform/modules/ec2/main.tf`:
```hcl
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name = "${var.environment}-high-cpu"
  metric_name = "CPUUtilization"
  threshold = 80
  # ... more config
}
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Variable not found" | Check `terraform.auto.tfvars` exists and is in working directory |
| S3 bucket name exists | Edit `terraform.auto.tfvars` with unique bucket name suffix |
| SSH connection refused | Verify security group allows port 22 from your IP |
| Cost estimate too high | Review instance_type in environment config, reduce if needed |
| Deployment stuck on approval | Check approval policies in env0, request from correct stakeholder |

---

## Next Steps

1. **Read Full README**: `README.md` for complete documentation
2. **Understand Architecture**: `ARCHITECTURE.md` for diagrams and data flow
3. **Setup Env0**: `ENV0_DEPLOYMENT_GUIDE.md` for platform integration
4. **Customize**: Modify variables and modules for your use case
5. **Deploy**: Use workflows for multi-stage deployments
6. **Monitor**: Track costs and infrastructure health

---

## Key Files to Know

| File | Purpose |
|------|---------|
| `terraform/main.tf` | References all modules, entry point |
| `terraform/variables.tf` | Shared variables (environment, region, etc.) |
| `terraform/environments/dev/terraform.auto.tfvars` | Dev-specific values |
| `workflows/complete-deployment.yaml` | Multi-stage deployment workflow |
| `.gitignore` | Prevents sensitive files from git |

---

## Demo Tips

**Show cost optimization**: Compare environment configs showing different instance sizes and S3 policies

**Show multi-environment**: Deploy to dev, show outputs, then deploy to staging with different CIDR blocks

**Show dependencies**: Explain module structure - VPC is foundation, EC2 depends on everything

**Show env0 integration**: Create a workflow, run it, show approval gate and cost estimate

**Show security**: Point out IMDSv2, encrypted volumes, security groups, IAM policies

---

## Support

- **Terraform Docs**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Env0 Docs**: https://docs.env0.com
- **AWS Best Practices**: https://aws.amazon.com/architecture/

Enjoy the demo! 🚀
