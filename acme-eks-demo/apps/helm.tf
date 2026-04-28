resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.1"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  timeout    = 600

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

resource "helm_release" "payments_app" {
  name       = "payments-app"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
  version    = "15.14.0"
  namespace  = kubernetes_namespace.payments.metadata[0].name
  timeout    = 600

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
