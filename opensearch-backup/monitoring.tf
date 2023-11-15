resource "kubernetes_manifest" "prometheusrule" {
  count = var.prometheusrule_enabled ? 1 : 0

  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "PrometheusRule"

    "metadata" = {
      "labels" = merge(var.prometheusrule_labels, {
        "app.kubernetes.io/name"       = "opensearch-backup"
        "app.kubernetes.io/instance"   = var.name
        "app.kubernetes.io/managed-by" = "terraform"
      })

      "name"      = var.name
      "namespace" = var.prometheusrule_namespace
    }

    "spec" = {
      "groups" = [
        {
          "name" = "opensearch-snapshot.rules"

          "rules" = [
            {
              "alert" = "ElasticsearchSnaphotFailures"

              "annotations" = {
                "description" = "The are Elasticsearch snapshot failures for {{ $labels.job }} on repository {{ $labels.repository }}!"
                "runbook_url" = "https://github.com/skyscrapers/documentation/tree/master/runbook.md#alert-name-elasticsearchsnaphotfailures"
                "summary"     = "Elasticsearch snapshot FAILURE!"
              }

              "expr" = "increase(elasticsearch_snapshot_stats_snapshot_number_of_failures{repository=\"${opensearch_snapshot_repository.repo.name}\"}[${var.prometheusrule_query_period}]) > 0"
              "for"  = "5m"

              "labels" = merge(var.prometheusrule_alert_labels, {
                "severity" = var.prometheusrule_severity
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
