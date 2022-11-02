locals {
  elasticsearch_domain_endpoint = "https://${var.elasticsearch_endpoint}:443"
}

resource "helm_release" "elasticsearch_monitoring" {
  name        = "es-monitoring-${var.elasticsearch_domain_name}"
  repository  = "https://skyscrapers.github.io/charts"
  chart       = "elasticsearch-monitoring"
  version     = var.elasticsearch_monitoring_chart_version
  namespace   = var.kubernetes_namespace
  max_history = 10

  values = [
    templatefile("${path.module}/templates/elasticsearch-monitoring-values.yaml.tftpl", {
      cloudwatch_exporter_role = var.cloudwatch_exporter_role_arn
      elasticsearch_domain     = var.elasticsearch_domain_name
      elasticsearch_endpoint   = local.elasticsearch_domain_endpoint
      irsa_enabled             = var.irsa_enabled
      region                   = var.elasticsearch_domain_region
      es_exporter_memory       = var.es_exporter_memory
      cw_exporter_memory       = var.cw_exporter_memory
      sla                      = var.sla == null ? "" : var.sla
    })
  ]

  set {
    type  = "string"
    name  = "terraform_force_update_this_is_not_used"
    value = var.force_helm_update
  }
}
