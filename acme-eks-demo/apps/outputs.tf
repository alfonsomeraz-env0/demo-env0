output "payments_namespace" {
  value = kubernetes_namespace.payments.metadata[0].name
}

output "monitoring_namespace" {
  value = kubernetes_namespace.monitoring.metadata[0].name
}

output "ingress_namespace" {
  value = kubernetes_namespace.ingress.metadata[0].name
}

output "helm_releases" {
  value = {
    ingress    = helm_release.ingress_nginx.name
    prometheus = helm_release.prometheus.name
    payments   = helm_release.payments_app.name
  }
}
