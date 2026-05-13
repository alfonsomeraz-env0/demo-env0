# env0 Demo Repository

A collection of Infrastructure-as-Code demos for the **env0 platform**, covering Terraform, Terragrunt, CloudFormation, Ansible, and env0 Workflows across a range of real-world patterns.

Each folder is a standalone demo — import it into env0 as a template and deploy.

---

## Demo Index

### Terraform Modules

| Demo | Description |
|---|---|
| [`s3_bucket/`](./s3_bucket/README.md) | S3 bucket with versioning — beginner-friendly starting point |
| [`ec2/`](./ec2/README.md) | EC2 instance (AL2023, IMDSv2, encrypted EBS) |
| [`vpc/`](./vpc/README.md) | VPC with public subnet, IGW, and route table |
| [`security_group/`](./security_group/README.md) | Security group with fully configurable dynamic ingress rules |
| [`iam_role/`](./iam_role/README.md) | IAM role with optional instance profile and inline policy |
| [`terraform/`](./terraform/README.md) | Full-stack root module composing VPC + SG + IAM + EC2 + S3 |

### Advanced Patterns

| Demo | Description |
|---|---|
| [`ec2-ansible-demo/`](./ec2-ansible-demo/README.md) | Terraform + Ansible — provisions EC2 and configures it with Ansible in one env0 deploy |
| [`custom_flows/`](./custom_flows/README.md) | TFLint pre-deploy gate — blocks deployment if Terraform linting violations are found |
| [`cloudformation/`](./cloudformation/README.md) | CloudFormation via env0 — shows IaC-tool agnosticism |

### Terragrunt

| Demo | Description |
|---|---|
| [`terragrunt/`](./terragrunt/README.md) | Terragrunt root config — generates provider and version files dynamically |
| [`terragrunt-bootstrap/`](./terragrunt-bootstrap/README.md) | Creates the S3 + DynamoDB remote state backend for Terragrunt |

### env0 Workflows

| Demo | Description |
|---|---|
| [`workflows/`](./workflows/README.md) | Four-stage full-stack workflow: VPC → SG → S3 → EC2 with dependency ordering |
| [`terragrunt-workflow/`](./terragrunt-workflow/README.md) | Two-stage workflow: bootstrap state backend, then deploy Terragrunt stack |
| [`acme-eks-demo/`](./acme-eks-demo/README.md) | Multi-stage EKS workflow: infrastructure then applications, with approval gate |

### Coming Soon

| Demo | Description |
|---|---|
| [`mcp-demo/`](./mcp-demo/README.md) | MCP server integration — trigger env0 deployments from AI assistants |

---

## Quick Start

1. Fork or clone this repo
2. In env0, go to **Templates → Add Template**
3. Connect this repository and set the working directory to any demo folder
4. Configure variables as described in the folder's README
5. Deploy

---

## What Each Demo Covers

```
Beginner    s3_bucket → vpc → ec2
Intermediate  security_group → iam_role → terraform (full stack)
Advanced      ec2-ansible-demo → custom_flows → cloudformation
Workflows     workflows → terragrunt-workflow → acme-eks-demo
```

---

## AWS Resources Used

All demos target AWS. You'll need:
- AWS credentials configured in env0 (IAM user or OIDC role)
- Sufficient permissions for the resources each demo creates (EC2, S3, VPC, IAM, DynamoDB, CloudFormation)

---

## Repository Layout

```
demo-env0/
├── s3_bucket/              # Terraform — S3 bucket
├── ec2/                    # Terraform — EC2 instance
├── vpc/                    # Terraform — VPC + networking
├── security_group/         # Terraform — Security group
├── iam_role/               # Terraform — IAM role
├── terraform/              # Terraform — Full stack (modules)
│   └── modules/
│       ├── vpc/
│       ├── security_groups/
│       ├── iam/
│       ├── ec2/
│       └── s3/
├── ec2-ansible-demo/       # Terraform + Ansible
├── custom_flows/           # TFLint pre-deploy gate
├── cloudformation/         # CloudFormation
├── terragrunt/             # Terragrunt config
├── terragrunt-bootstrap/   # Terragrunt state backend
├── workflows/              # env0 Workflow — full stack
├── terragrunt-workflow/    # env0 Workflow — Terragrunt
├── acme-eks-demo/          # env0 Workflow — EKS
└── mcp-demo/               # Coming soon
```

---

## Documentation

- [env0 Docs](https://docs.env0.com)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terragrunt Docs](https://terragrunt.gruntwork.io/docs)
