resource "kubernetes_manifest" "prometheusrule" {
  count = var.prometheusrule_enabled ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/templates/prometheusrule.yaml.tftpl", {
    alert_labels = yamlencode(var.prometheusrule_alertlabels)
    labels       = yamlencode(var.prometheusrule_labels)
    name         = var.name
    namespace    = var.prometheusrule_namespace
    repository   = opensearch_snapshot_repository.repo.name
    query_period = var.prometheusrule_query_period
    severity     = var.prometheusrule_severity
  }))

  field_manager {
    force_conflicts = true
  }
}
