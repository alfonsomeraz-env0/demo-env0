resource "aws_iam_role" "eks_cluster" {
  name = "acme-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })

  tags = { App = "payments" }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "acme" {
  name     = "acme-financial-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.32"

  vpc_config {
    subnet_ids             = aws_subnet.public[*].id
    endpoint_public_access = true
  }

  tags = {
    Name = "acme-financial-eks"
    App  = "payments"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_iam_role" "eks_nodes" {
  name = "acme-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# Explicit node security group — blocks all internet inbound, allows only
# node-to-node and EKS control plane communication
resource "aws_security_group" "eks_nodes" {
  name        = "acme-eks-nodes-sg"
  description = "EKS worker nodes - no direct internet inbound"
  vpc_id      = aws_vpc.acme.id

  ingress {
    description = "node to node"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "control plane to nodes"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.acme.vpc_config[0].cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "acme-eks-nodes-sg" }
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix = "acme-eks-nodes-"

  vpc_security_group_ids = [
    aws_eks_cluster.acme.vpc_config[0].cluster_security_group_id,
    aws_security_group.eks_nodes.id,
  ]

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "acme-payments-node" }
  }
}

# ─── DRIFT TARGET ─────────────────────────────────────────────────────────────
# To manufacture drift: change desired_size to 5 in the AWS console or via CLI:
#   aws eks update-nodegroup-config \
#     --cluster-name acme-financial-eks \
#     --nodegroup-name acme-payments-nodes \
#     --scaling-config desiredSize=5
resource "aws_eks_node_group" "payments" {
  cluster_name    = aws_eks_cluster.acme.name
  node_group_name = "acme-payments-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.public[*].id
  instance_types  = ["t3.small"]

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 10
  }

  tags = {
    Name       = "acme-payments-nodes"
    App        = "payments"
    CostCenter = "engineering"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.eks_ecr,
  ]
}
# ──────────────────────────────────────────────────────────────────────────────
