# Architecture Overview

## Infrastructure Dependency Graph

```
                    ┌─────────────────┐
                    │   Variables     │
                    │  (Shared Vars)  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
         ┌────▼────┐    ┌────▼────┐  ┌────▼────┐
         │   VPC   │    │   S3    │  │  Sec    │
         │ Module  │    │ Module  │  │ Groups  │
         │         │    │         │  │ Module  │
         └────┬────┘    └────┬────┘  └────┬────┘
              │              │            │
              │              └────┬───────┘
              │                   │
         ┌────▼────────────────────▼────┐
         │      IAM Module              │
         │   (Depends on S3 Bucket)     │
         └────┬───────────────────────┘
              │
         ┌────▼──────────────────────┐
         │    EC2 Module             │
         │ (Depends on all above)    │
         └─────────────────────────┘
```

## Module Relationships

### VPC Module
- **Creates**: VPC, Public Subnet, Internet Gateway, Route Table
- **Provides**: VPC ID, Subnet ID (for EC2), CIDR blocks
- **Dependencies**: None (foundation)
- **Outputs Used By**: Security Groups, EC2

### Security Groups Module
- **Creates**: EC2 security group, S3 access security group
- **Provides**: Security group IDs for network rules
- **Dependencies**: VPC (requires VPC ID)
- **Outputs Used By**: EC2

### S3 Module
- **Creates**: S3 bucket, versioning, encryption, public access block, lifecycle policies
- **Provides**: Bucket ID, ARN, domain name
- **Dependencies**: None (independent)
- **Outputs Used By**: IAM (for S3 access policy)

### IAM Module
- **Creates**: EC2 IAM role, S3 access policy, instance profile
- **Provides**: Instance profile name, role ARN
- **Dependencies**: S3 (requires bucket name for policy)
- **Outputs Used By**: EC2 (instance profile)

### EC2 Module
- **Creates**: EC2 instance, EBS root volume, IAM instance profile attachment
- **Provides**: Instance ID, public/private IPs, availability zone
- **Dependencies**: VPC (subnet), Security Groups, IAM (instance profile)
- **Outputs Used By**: None (end resource)

## Deployment Sequence

### Manual Terraform Deployment

```
1. terraform init           # Initialize Terraform backend
2. terraform validate       # Validate configuration syntax
3. terraform plan           # Generate execution plan
4. terraform apply          # Create resources in order:
   a. VPC (no dependencies)
   b. S3 (no dependencies)
   c. Security Groups (depends on VPC)
   d. IAM (depends on S3)
   e. EC2 (depends on VPC, Security Groups, IAM)
```

### Env0 Workflow: Complete Stack

```
PLAN PHASE (Parallel):
├─ Plan Foundation (VPC + Security Groups)
├─ Plan Storage (S3)
└─ Plan Compute (EC2 + IAM)

APPROVAL PHASE:
└─ Review combined plan and cost estimate

APPLY PHASE (Sequential):
├─ Apply Foundation
│  ├─ Create VPC
│  └─ Create Security Groups
├─ Apply Storage
│  └─ Create S3 Bucket
├─ Apply Compute
│  ├─ Create IAM Role
│  └─ Create EC2 Instance
└─ Retrieve Outputs
```

## Data Flow

### Resource Creation Flow

```
User Request
    │
    ▼
Environment Selection (dev/staging/prod)
    │
    ▼
Load terraform.auto.tfvars
    │
    ▼
Resolve Module Inputs
    │
    ├──► VPC Module ──► VPC, Subnet, IGW
    │
    ├──► S3 Module ──► S3 Bucket with Lifecycle
    │
    ├──► Security Groups Module (uses VPC outputs)
    │    │
    │    └──► EC2 & S3 Security Groups
    │
    ├──► IAM Module (uses S3 bucket name)
    │    │
    │    └──► EC2 Role, Instance Profile
    │
    └──► EC2 Module (uses VPC, SG, IAM outputs)
         │
         └──► EC2 Instance, EBS Volume
```

## Variable Inheritance

### Root Variables
Defined in `terraform/variables.tf`:
- `environment` (dev/staging/prod)
- `aws_region`, `availability_zone_suffix`
- `vpc_cidr`, `public_subnet_cidr`
- `instance_type`, `instance_name`, `root_volume_size`
- `s3_bucket_name`, S3 lifecycle config
- `allowed_ssh_cidrs`

### Environment Overrides
Each environment (`terraform/environments/{env}/terraform.auto.tfvars`):
- Overrides root variables
- Provides environment-specific CIDR blocks
- Adjusts instance sizing (micro/small/medium)
- Configures security (SSH access restrictions)
- Sets S3 retention policies

### Module Variables
Each module has its own `variables.tf`:
- Modules receive variables from root module
- Some modules compute derived values
- Example: EC2 module derives AZ from region + suffix

## Network Architecture

### VPC Layout

```
                AWS Region: us-east-1
            ╔═══════════════════════════╗
            ║    VPC: 10.0.0.0/16       ║
            ║                           ║
            ║  ┌─────────────────────┐  ║
            ║  │ Public Subnet       │  ║
            ║  │ 10.0.1.0/24         │  ║
            ║  │                     │  ║
            ║  │ ┌─────────────────┐ │  ║
            ║  │ │ EC2 Instance    │ │  ║
            ║  │ │ 10.0.1.x        │ │  ║
            ║  │ │ Public IP: x.x.x│ │  ║
            ║  │ └─────────────────┘ │  ║
            ║  └─────────────────────┘  ║
            ║             │             ║
            ║    ┌────────▼────────┐    ║
            ║    │ Internet Gateway│    ║
            ║    │ (IGW)           │    ║
            ║    └────────┬────────┘    ║
            ╚═════════════╪════════════╝
                          │
                          ▼
                    AWS Internet
```

### Security Groups

```
EC2 Security Group:
├─ Inbound:
│  ├─ SSH (22) from 0.0.0.0/0 (dev) or 10.0.0.0/8 (prod)
│  ├─ HTTP (80) from 0.0.0.0/0
│  └─ HTTPS (443) from 0.0.0.0/0
└─ Outbound: All traffic to 0.0.0.0/0

S3 Access Security Group:
├─ Inbound: None (not attached to EC2)
└─ Outbound: HTTPS (443) to 0.0.0.0/0 (for S3 API calls)
```

## IAM Permissions Model

```
EC2 Instance
    │
    ▼
EC2 Instance Profile
    │
    ▼
EC2 IAM Role
    │
    ├─ Policy: S3 Access
    │  ├─ s3:GetObject
    │  ├─ s3:PutObject
    │  └─ s3:ListBucket
    │
    └─ Assumed by: ec2.amazonaws.com
```

## Environment Isolation

Each environment has:
- **Separate VPC**: No network overlap (dev=10.0, staging=10.1, prod=10.2)
- **Isolated IAM roles**: Environment-specific naming
- **Distinct S3 buckets**: Separate data storage
- **Environment tags**: All resources tagged with environment name

```
Development              Staging                  Production
├─ VPC: 10.0.0.0/16     ├─ VPC: 10.1.0.0/16      ├─ VPC: 10.2.0.0/16
├─ t3.micro             ├─ t3.small               ├─ t3.medium
├─ Open SSH (0.0.0.0/0) ├─ Private SSH            ├─ Private SSH
├─ S3: 7-day retention  ├─ S3: 30-day retention  └─ S3: 90-day retention
└─ No archival          └─ 60-day archival       └─ 30-day archival
```

## Cost Structure

### Fixed Costs
- **EC2**: $0.0104/hour (t3.micro) in us-east-1
- **EBS**: $0.10/GB-month (gp3, encrypted)

### Variable Costs
- **Data Transfer**: $0.02/GB out (beyond free tier)
- **S3 Storage**: $0.023/GB-month (STANDARD), $0.0125/GB-month (STANDARD_IA)
- **S3 API Calls**: $0.0004/1000 GET, $0.005/1000 PUT

### Estimated Monthly
- **Dev**: $5-10 (free tier eligible)
- **Staging**: $15-25
- **Production**: $25-40

## High Availability (Future Enhancement)

### Multi-AZ Deployment
```
Current: Single AZ
├─ Single EC2 instance
├─ Single subnet

Future: Multi-AZ
├─ Load Balancer (ALB/NLB)
├─ Auto Scaling Group
├─ Multiple subnets (one per AZ)
└─ RDS Multi-AZ database
```

### Disaster Recovery
```
Active Region (Primary)         Backup Region (Secondary)
├─ Production VPC               ├─ Standby VPC
├─ EC2 Instances                ├─ Warm Standby EC2
├─ Primary RDS                  ├─ RDS Read Replica
└─ S3 (source)                  └─ S3 (cross-region replication)
```

## Conclusion

This architecture demonstrates:
- **Modularity**: Independent, reusable modules
- **Dependency Management**: Clear relationships between resources
- **Multi-Environment**: Identical code, different configurations
- **Security**: Isolated networks, limited permissions
- **Scalability**: Foundation for high-availability deployments
- **Cost Optimization**: Environment-appropriate sizing and lifecycle policies
