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


resource "helm_release" "prometheus" {
  # depends_on = [ kubernetes_manifest.skybytech-require-non-root, kubernetes_manifest.skybytech-require-resources ]
  name             = "prome"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"

  namespace        = "monitoring"
  create_namespace = true
}

# resource "helm_release" "kyverno" {
#   name             = "kyverno-helm"
#   repository       = "https://kyverno.github.io/kyverno/"
#   chart            = "kyverno"

#   namespace        = "kyverno-ns"
#   create_namespace = true
# }

resource "kubernetes_manifest" "skybytech-require-non-root" {
  manifest = yamldecode(file("../policies/require-non-root.yaml"))
}

resource "kubernetes_manifest" "skybytech-require-resources" {
  manifest = yamldecode(file("../policies/require-resources.yaml"))
}

resource "helm_release" "skybytech" {
  depends_on = [ helm_release.prometheus, kubernetes_namespace.this ]
  name             = "skybytech"
  chart            = "../helm/skybyte-app"

}