resource "kubernetes_namespace" "payments" {
  metadata {
    name = "payments"
    labels = {
      app         = "payments"
      environment = "production"
      managed-by  = "env0"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      app        = "monitoring"
      managed-by = "env0"
    }
  }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
    labels = {
      app        = "ingress"
      managed-by = "env0"
    }
  }
}
