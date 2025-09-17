data "aws_opensearch_domain" "os" {
  domain_name = var.domain_name
}

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
      opensearch_uri    = "https://${data.aws_opensearch_domain.os.endpoint}"
      prometheus_labels = yamlencode(var.monitoring_prometheus_labels)
      repository        = opensearch_snapshot_repository.repo.name
      role_arn          = aws_iam_role.elasticsearch_exporter[0].arn
      rule_query_period = var.monitoring_prometheusrule_query_period

      alert_labels = yamlencode(merge(var.monitoring_prometheusrule_alert_labels, {
        "severity" = var.monitoring_prometheusrule_severity
      }))

      tolerations  = var.monitoring_elasticsearch_exporter_tolerations != null ? yamlencode(var.monitoring_elasticsearch_exporter_tolerations) : ""
      nodeSelector = var.monitoring_elasticsearch_exporter_nodeSelector != null ? yamlencode(var.monitoring_elasticsearch_exporter_nodeSelector) : ""
    })
  ]
}

data "aws_iam_policy_document" "elasticsearch_exporter_assume" {
  count = var.monitoring_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.eks_cluster_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.eks_cluster_oidc_provider_name}:sub"
      values   = ["system:serviceaccount:${var.monitoring_namespace}:${var.name}-monitoring"]
    }
  }
}

data "aws_iam_policy_document" "elasticsearch_exporter" {
  count = var.monitoring_enabled ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["es:ESHttpGet"]
    resources = ["${data.aws_opensearch_domain.os.arn}/*"]
  }
}

resource "aws_iam_role" "elasticsearch_exporter" {
  count = var.monitoring_enabled ? 1 : 0

  name               = "${var.name}-monitoring"
  assume_role_policy = data.aws_iam_policy_document.elasticsearch_exporter_assume[0].json
}

resource "aws_iam_role_policy" "elasticsearch_exporter" {
  count = var.monitoring_enabled ? 1 : 0

  role   = aws_iam_role.elasticsearch_exporter[0].id
  policy = data.aws_iam_policy_document.elasticsearch_exporter[0].json
}
