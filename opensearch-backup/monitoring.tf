resource "helm_release" "elasticsearch_exporter" {
  count = var.monitoring_enabled ? 1 : 0

  name        = "elasticsearch-exporter-${var.name}"
  repository  = "oci://ghcr.io/prometheus-community/charts"
  chart       = "prometheus-elasticsearch-exporter"
  version     = var.monitoring_elasticsearch_exporter_version
  namespace   = var.monitoring_namespace
  max_history = 10

  values = [
    templatefile("${path.module}/templates/elasticsearch-exporter-values.yaml.tftpl", {
      opensearch_endpoint = 

      tolerations  = var.monitoring_elasticsearch_exporter_tolerations != null ? yamlencode(var.monitoring_elasticsearch_exporter_tolerations) : ""
      nodeSelector = var.monitoring_elasticsearch_exporter_nodeSelector != null ? yamlencode(var.monitoring_elasticsearch_exporter_nodeSelector) : ""
    })
  ]
}

resource "kubernetes_manifest" "prometheusrule" {
  count = var.monitoring_enabled ? 1 : 0

  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "PrometheusRule"

    "metadata" = {
      "labels" = merge(var.monitoring_prometheusrule_labels, {
        "app.kubernetes.io/name"       = "opensearch-backup"
        "app.kubernetes.io/instance"   = var.name
        "app.kubernetes.io/managed-by" = "terraform"
      })

      "name"      = var.name
      "namespace" = var.monitoring_namespace
    }

    "spec" = {
      "groups" = [
        {
          "name" = "opensearch-snapshot.rules"

          "rules" = [
            {
              "alert" = "OpenSearchSnaphotFailures"

              "annotations" = {
                "description" = "There are OpenSearch snapshot failures for {{ $labels.job }} on repository {{ $labels.repository }}!"
                "runbook_url" = "https://github.com/skyscrapers/documentation/tree/master/runbook.md#alert-name-opensearchsnaphotfailures"
                "summary"     = "OpenSearch snapshot FAILURE!"
              }

              "expr" = "increase(elasticsearch_snapshot_stats_snapshot_number_of_failures{repository=\"${opensearch_snapshot_repository.repo.name}\"}[${var.monitoring_prometheusrule_query_period}]) > 0"
              "for"  = "5m"

              "labels" = merge(var.monitoring_prometheusrule_alert_labels, {
                "severity" = var.monitoring_prometheusrule_severity
              })
            }
          ]
        }
      ]
    }
  }

  field_manager {
    force_conflicts = true
  }
}
