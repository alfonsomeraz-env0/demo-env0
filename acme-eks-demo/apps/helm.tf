resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.1"
  namespace  = kubernetes_namespace.ingress.metadata[0].name

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

  set {
    name  = "controller.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }

  depends_on = [kubernetes_namespace.ingress]
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "57.0.3"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "7d"
  }

  set {
    name  = "prometheus.prometheusSpec.replicas"
    value = "1"
  }

  depends_on = [kubernetes_namespace.monitoring]
}

resource "helm_release" "payments_app" {
  name       = "payments-app"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
  version    = "15.14.0"
  namespace  = kubernetes_namespace.payments.metadata[0].name

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [<<-EOT
    podLabels:
      app: payments
      managed-by: env0
      environment: production
    EOT
  ]

  depends_on = [kubernetes_namespace.payments]
}
