resource "helm_release" "elasticsearch_exporter" {
  count = var.monitoring_enabled ? 1 : 0

  name        = "${var.name}-monitoring"
  repository  = "oci://ghcr.io/prometheus-community/charts"
  chart       = "prometheus-elasticsearch-exporter"
  version     = var.monitoring_elasticsearch_exporter_version
  namespace   = var.monitoring_namespace
  max_history = 10

  values = [
    templatefile("${path.module}/templates/elasticsearch-exporter-values.yaml.tftpl", {
      name              = "${var.name}-monitoring"
      opensearch_uri    = var.opensearch_endpoint
      prometheus_labels = yamlencode(var.monitoring_prometheus_labels)
      repository        = opensearch_snapshot_repository.repo.name
      rule_query_period = var.monitoring_prometheusrule_query_period

      alert_labels = yamlencode(merge(var.monitoring_prometheusrule_alert_labels, {
        "severity" = var.monitoring_prometheusrule_severity
      }))

      tolerations  = var.monitoring_elasticsearch_exporter_tolerations != null ? yamlencode(var.monitoring_elasticsearch_exporter_tolerations) : ""
      nodeSelector = var.monitoring_elasticsearch_exporter_nodeSelector != null ? yamlencode(var.monitoring_elasticsearch_exporter_nodeSelector) : ""
    })
  ]
}
