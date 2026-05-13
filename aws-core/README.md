# AWS Core Demos

Three demos covering the most common AWS compute and data patterns, each deployable as a standalone env0 environment.

## Demos

| Demo | IaC Type | Description |
|---|---|---|
| [`ec2-ansible/`](./ec2-ansible/README.md) | Terraform + Ansible | Provision EC2 instances and configure them with Ansible in a single env0 deployment |
| [`ecs-fargate/`](./ecs-fargate/README.md) | Terraform | Serverless containers on ECS Fargate with ALB, ECR, and CloudWatch |
| [`vpc-rds/`](./vpc-rds/README.md) | Terraform | Two-tier VPC (public app + private DB) with an encrypted RDS instance |

## When to Use Each

**EC2 + Ansible** — You need full control over the server, custom software installs, or configuration management at the OS level.

**ECS Fargate** — You have a containerized workload and want serverless compute with no EC2 instances to manage.

**VPC + RDS** — You need a managed relational database in a private network, typically as the data tier for any of the above.

## Combining These Demos

These three demos are designed to layer on top of each other:

```
vpc-rds        →  creates the VPC and private RDS instance
ec2-ansible    →  deploys into the public subnets, app SG from vpc-rds
ecs-fargate    →  deploys into the public subnets with ALB
```

Use env0 Workflows to orchestrate them in dependency order — see [`multi-tier-workflow/`](../multi-tier-workflow/README.md) for the pattern.
