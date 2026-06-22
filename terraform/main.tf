resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_resource_quota" "memory" {
  metadata {
    name      = "memory-quota"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    hard = {
      "limits.memory" = var.memory_quota
    }
  }
}

resource "kubernetes_secret" "api_token" {
  metadata {
    name      = "api-token"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    token = var.api_token
  }

  type = "Opaque"
}

resource "kubernetes_manifest" "skybytech-require-non-root" {
  manifest = yamldecode(file("../policies/require-non-root.yaml"))
}

resource "kubernetes_manifest" "skybytech-require-resources" {
  manifest = yamldecode(file("../policies/require-resources.yaml"))
}