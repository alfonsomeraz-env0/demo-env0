# ECS Fargate Demo

Deploys a containerized application on AWS ECS Fargate with an Application Load Balancer, ECR repository, and CloudWatch logging — all managed through env0.

## Architecture

```
Internet
  │
  ▼
ALB (port 80)
  │
  ▼
ECS Fargate Service
  ├── Task Definition (awsvpc networking)
  ├── CloudWatch Logs
  └── ECR Repository (image source)

VPC
  ├── Public Subnet A (ECS tasks + ALB)
  └── Public Subnet B (ECS tasks + ALB)
```

> Tasks run in public subnets with `assign_public_ip = true` for simplicity. For production, place tasks in private subnets behind a NAT gateway.

## What This Creates

| Resource | Description |
|---|---|
| VPC + 2 public subnets | Spanning two AZs for ALB requirements |
| Internet Gateway + route table | Public internet access |
| ALB + target group + listener | HTTP on port 80, forwards to container |
| Security groups | ALB open to internet; ECS tasks accept only ALB traffic |
| ECR repository | Private registry for your Docker images |
| ECS Cluster | Fargate launch type with Container Insights enabled |
| ECS Task Definition | `awsvpc` networking, configurable CPU/memory |
| ECS Service | Desired count, ALB-integrated |
| CloudWatch Log Group | Container stdout/stderr, 7-day retention |
| IAM Task Execution Role | Allows ECS to pull from ECR and write to CloudWatch |

## env0 Setup

| Field | Value |
|---|---|
| **IaC Type** | Terraform |
| **Terraform Version** | >= 1.0 |
| **Working Directory** | `aws-core/ecs-fargate` |

## Variables

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `aws_region` | string | `us-east-1` | No | AWS region |
| `environment` | string | `dev` | No | Environment name |
| `app_name` | string | `demo-app` | No | Used for ECS service, task def, ECR repo |
| `vpc_cidr` | string | `10.0.0.0/16` | No | VPC CIDR block |
| `container_image` | string | `nginx:latest` | No | Docker image to run |
| `container_port` | number | `80` | No | Port the container listens on |
| `health_check_path` | string | `/` | No | ALB health check path |
| `task_cpu` | number | `256` | No | Fargate CPU units |
| `task_memory` | number | `512` | No | Fargate memory in MiB |
| `desired_count` | number | `1` | No | Number of running tasks |

### Valid CPU / Memory Combinations

| CPU | Memory options |
|---|---|
| 256 | 512, 1024, 2048 |
| 512 | 1024–4096 |
| 1024 | 2048–8192 |
| 2048 | 4096–16384 |
| 4096 | 8192–30720 |

## Outputs

| Name | Description |
|---|---|
| `alb_url` | `http://` URL to access the application |
| `alb_dns_name` | Raw ALB DNS name |
| `ecr_repository_url` | ECR URI for pushing custom images |
| `ecs_cluster_name` | ECS cluster name |
| `ecs_service_name` | ECS service name |
| `cloudwatch_log_group` | CloudWatch log group path |

## How to Run

1. Create a new environment in env0 with **IaC Type: Terraform**
2. Set working directory to `aws-core/ecs-fargate`
3. Deploy — the default image is `nginx:latest`, visible immediately at the ALB URL
4. To deploy a custom image, push to the ECR repo and update `container_image`

## Pushing a Custom Image

After deploy, the env0.yaml prints the exact commands:

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <ecr-url>

docker tag myapp:latest <ecr-url>:latest
docker push <ecr-url>:latest
```

Then update the `container_image` variable in env0 to the ECR URI and redeploy.
