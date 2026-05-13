output "eks_cluster_name" {
  value = aws_eks_cluster.acme.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.acme.endpoint
}

output "node_group_desired_size" {
  description = "Current desired node count — watch this for drift"
  value       = aws_eks_node_group.payments.scaling_config[0].desired_size
}

output "vpc_id" {
  value = aws_vpc.acme.id
}
