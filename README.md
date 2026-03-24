# Demo Env0 Repository

A comprehensive, modular Infrastructure-as-Code (IaC) repository demonstrating cloud infrastructure deployment on the **env0 platform** with multi-environment support, resource modularization, and workflow automation.

## Overview

This repository showcases best practices for managing AWS infrastructure using Terraform with a focus on:

- **Modular Architecture**: Reusable Terraform modules for VPC, Security Groups, EC2, S3, and IAM resources
- **Multi-Environment Support**: Separate configurations for dev, staging, and production environments
- **Dependency Management**: Automated workflows that respect resource dependencies
- **Infrastructure as Code**: Version-controlled, reproducible infrastructure deployments
- **Env0 Integration**: Native workflows and configurations optimized for the env0 platform

## Repository Structure

```
demo-env0/
├── terraform/
│   ├── modules/                    # Reusable Terraform modules
│   │   ├── vpc/                    # VPC, subnets, internet gateway
│   │   ├── security_groups/        # Security groups for EC2 and S3 access
│   │   ├── ec2/                    # EC2 instance with optimized settings
│   │   ├── s3/                     # S3 bucket with versioning & lifecycle
│   │   └── iam/                    # IAM roles and instance profiles
│   ├── environments/               # Environment-specific configurations
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   ├── main.tf                     # Root module composition
│   ├── variables.tf                # Root variables
│   └── outputs.tf                  # Root outputs
├── workflows/                      # Env0 deployment workflows
│   ├── vpc-deployment.yaml         # Foundation infrastructure workflow
│   ├── complete-deployment.yaml    # Full stack with dependency management
│   └── destroy-environment.yaml    # Safe environment teardown
└── README.md                       # This file
```

## Modules

### VPC Module (`terraform/modules/vpc/`)
Deploys foundational networking infrastructure:
- AWS VPC with configurable CIDR block
- Public subnet with auto-assigned public IPs
- Internet Gateway for external connectivity
- Route table configuration

**Dependencies**: None (foundation module)

### Security Groups Module (`terraform/modules/security_groups/`)
Manages inbound/outbound traffic rules:
- **EC2 Security Group**: SSH (22), HTTP (80), HTTPS (443)
- **S3 Access Security Group**: HTTPS (443) for S3 communication
- Configurable CIDR blocks for SSH access

**Dependencies**: VPC module

### IAM Module (`terraform/modules/iam/`)
Provides identity and access management:
- EC2 instance role for service permissions
- S3 access policy for EC2 instances
- Instance profile for role attachment

**Dependencies**: S3 module (requires bucket name)

### EC2 Module (`terraform/modules/ec2/`)
Deploys compute instances:
- Amazon Linux 2023 AMI (latest)
- Configurable instance types per environment
- Encrypted EBS root volume
- IMDSv2 enforcement for security
- CloudWatch monitoring enabled

**Dependencies**: VPC, Security Groups, IAM modules

### S3 Module (`terraform/modules/s3/`)
Creates object storage with safety features:
- Bucket versioning enabled
- Server-side encryption (AES256)
- Public access blocking
- Lifecycle policies for cost optimization
- Configurable object retention and archival

**Dependencies**: None (can be deployed independently)

## Environments

### Development (`terraform/environments/dev/`)
- **Instance Type**: `t3.micro` (free tier eligible)
- **VPC CIDR**: `10.0.0.0/16`
- **AZ Suffix**: `a`
- **SSH Access**: Open (`0.0.0.0/0`)
- **S3 Retention**: 7 days
- **Lifecycle Archival**: Disabled

### Staging (`terraform/environments/staging/`)
- **Instance Type**: `t3.small`
- **VPC CIDR**: `10.1.0.0/16`
- **AZ Suffix**: `b`
- **SSH Access**: Private only (`10.0.0.0/8`)
- **S3 Retention**: 30 days
- **Lifecycle Archival**: Enabled (60-day transition)

### Production (`terraform/environments/prod/`)
- **Instance Type**: `t3.medium`
- **VPC CIDR**: `10.2.0.0/16`
- **AZ Suffix**: `c`
- **SSH Access**: Private only (`10.0.0.0/8`)
- **S3 Retention**: 90 days
- **Lifecycle Archival**: Enabled (30-day transition)

## Workflows

Env0 workflows provide orchestrated, multi-step deployments with dependency management and safety controls.

### VPC Deployment (`workflows/vpc-deployment.yaml`)
Deploys networking infrastructure as the foundation:
1. Validates Terraform configuration
2. Plans VPC changes
3. Requires approval before applying
4. Deploys VPC and routes

**Triggers**: Manual or weekly schedule

### Complete Stack Deployment (`workflows/complete-deployment.yaml`)
Orchestrates full infrastructure with dependency management:

**Stages (in order)**:
1. **Foundation**: VPC and Security Groups
2. **Storage**: S3 bucket with lifecycle policies
3. **Compute**: IAM roles and EC2 instances

**Features**:
- Parallel planning of independent stages
- Sequential application to maintain dependencies
- Auto-approve option for CI/CD integration
- Email and Slack notifications on completion
- Parameterized for environment selection

### Destroy Environment (`workflows/destroy-environment.yaml`)
Safely tears down infrastructure in reverse dependency order:

**Stages (in order)**:
1. Destroy EC2 and IAM
2. Destroy S3 buckets
3. Destroy VPC and Security Groups

**Safety Features**:
- Requires explicit approval
- Prevents accidental production destruction
- Email and Slack notifications on completion

## Getting Started

### Prerequisites
- Terraform >= 1.0
- AWS credentials configured (via `~/.aws/credentials` or environment variables)
- Env0 CLI (for workflow management)

### Quick Start: Dev Environment

1. **Initialize Terraform**
   ```bash
   cd terraform/environments/dev
   terraform init
   ```

2. **Review the Plan**
   ```bash
   terraform plan -var-file=terraform.auto.tfvars
   ```

3. **Deploy**
   ```bash
   terraform apply -var-file=terraform.auto.tfvars
   ```

4. **Access Outputs**
   ```bash
   terraform output
   ```

### Deploying to Staging/Production

```bash
# Staging
cd terraform/environments/staging
terraform init
terraform plan -var-file=terraform.auto.tfvars
terraform apply -var-file=terraform.auto.tfvars

# Production (requires approval)
cd terraform/environments/prod
terraform init
terraform plan -var-file=terraform.auto.tfvars
terraform apply -var-file=terraform.auto.tfvars
```

## Environment Variables

Configure AWS credentials:

```bash
export AWS_ACCESS_KEY_ID="your-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"
```

## Outputs

After deployment, retrieve infrastructure details:

```bash
# List all outputs
terraform output

# Get specific output
terraform output -raw instance_public_ip
```

**Key Outputs**:
- `vpc_id`: VPC identifier
- `instance_public_ip`: EC2 public IP address
- `s3_bucket_id`: S3 bucket name
- `s3_bucket_arn`: S3 bucket ARN

## Workflow Integration with Env0

1. **Connect Repository**: Link this repo to your env0 account
2. **Select Workflow**: Choose from VPC, Complete Stack, or Destroy workflows
3. **Configure Parameters**: Select environment and options
4. **Review Plan**: Approve infrastructure changes
5. **Deploy**: Execute the workflow with automatic dependency management

### Manual Workflow Execution via CLI

```bash
# List available workflows
env0 workflows list

# Run complete stack deployment
env0 workflows run complete-deployment.yaml \
  --parameter environment=dev \
  --parameter auto_approve=false
```

## Cost Optimization

### Development
- Uses `t3.micro` (free tier eligible within 12 months)
- Minimal S3 lifecycle management
- Open SSH access for testing

### Staging & Production
- S3 lifecycle policies automatically transition objects to cheaper storage (STANDARD_IA)
- Monitoring enabled for cost visibility
- Private networking reduces data transfer costs

### Estimated Monthly Costs (Single Region)
- **Dev**: ~$5-10 (EC2 + S3)
- **Staging**: ~$15-20 (EC2 + S3)
- **Production**: ~$25-35 (EC2 + S3 + Backups)

*Costs vary by region and usage patterns*

## Security Best Practices

✅ **Implemented**:
- IMDSv2 enforcement on EC2 (prevents SSRF attacks)
- Encrypted EBS volumes
- S3 public access blocking
- Security groups with least-privilege rules
- IAM roles instead of access keys
- VPC isolation per environment
- CloudWatch monitoring enabled

⚠️ **Recommended Additions**:
- VPC Flow Logs for network monitoring
- CloudTrail for API logging
- WAF for public-facing resources
- KMS encryption for S3 at rest
- Automated backup policies
- AWS Config for compliance monitoring

## Troubleshooting

### S3 Bucket Name Already Exists
S3 bucket names are globally unique. Edit `terraform.auto.tfvars` and change:
```hcl
s3_bucket_name = "demo-env0-dev-bucket-<unique-suffix>"
```

### Terraform State Lock
If deployment fails and Terraform locks the state:
```bash
terraform force-unlock <LOCK_ID>
```

### Instance SSH Access
```bash
ssh -i /path/to/key ec2-user@<PUBLIC_IP>
```

### View Terraform Logs
```bash
export TF_LOG=DEBUG
terraform plan
```

## Cleanup

**Destroy specific environment**:
```bash
cd terraform/environments/dev
terraform destroy -var-file=terraform.auto.tfvars
```

**Or use the Destroy workflow via env0**:
```bash
env0 workflows run destroy-environment.yaml --parameter environment=dev
```

## Contributing

1. Make infrastructure changes in module files
2. Update version in `main.tf`
3. Test in dev environment first
4. Submit changes with detailed descriptions
5. Use workflows for staging/prod deployments

## Demo Scenarios

This repository is ideal for demonstrating:

1. **Multi-Environment IaC**: Show dev/staging/prod configurations
2. **Module Reusability**: Explain how modules reduce code duplication
3. **Dependency Management**: Workflows respect resource creation order
4. **Cost Optimization**: Lifecycle policies and instance sizing
5. **Security Controls**: Network isolation and IAM policies
6. **Env0 Features**: Workflow orchestration and approval gates

## License

This demo repository is open source and available for educational and demonstration purposes.

## Support

For issues or questions:
- Check [Terraform AWS Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Review [Env0 Documentation](https://docs.env0.com)
- Open an issue in this repository
