terraform {
  required_version = ">= 0.12"
}

locals {
  elasticsearch_domain_name     = join("", data.terraform_remote_state.elasticsearch.*.outputs.es_domain_name)
  elasticsearch_domain_endpoint = "https://${join("", data.terraform_remote_state.elasticsearch.*.outputs.es_logs_endpoint)}:443"
  elasticsearch_domain_region   = join("", data.terraform_remote_state.elasticsearch.*.outputs.es_domain_region)
}

data "aws_iam_policy_document" "cloudwatch_exporter_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.workers_instance_role_name}",
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_exporter" {
  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "cloudwatch_exporter" {
  name               = "${local.cluster_name}_elasticsearch_monitoring"
  path               = "/kube2iam/"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_exporter_assume[0].json
}

resource "aws_iam_role_policy" "cloudwatch_exporter" {
  role   = aws_iam_role.cloudwatch_exporter[0].id
  policy = data.aws_iam_policy_document.cloudwatch_exporter[0].json
}

data "template_file" "elasticsearch_monitoring_helm_values" {
  template = file("${path.module}/templates/elasticsearch-monitoring-values.yaml.tpl")

  vars = {
    elasticsearch_endpoint   = local.elasticsearch_domain_endpoint
    cloudwatch_exporter_role = aws_iam_role.cloudwatch_exporter[0].arn
    region                   = local.elasticsearch_domain_region
    elasticsearch_domain     = local.elasticsearch_domain_name
  }
}

resource "helm_release" "elasticsearch_monitoring" {
  name       = "logging-es-monitor"
  repository = "https://skyscrapers.github.io/charts"
  chart      = "elasticsearch-monitoring"
  version    = var.elasticsearch_monitoring_chart_version
  namespace  = kubernetes_namespace.infrastructure.metadata[0].name

  values = [
    data.template_file.elasticsearch_monitoring_helm_values[0].rendered,
  ]

  set_string {
    name  = "terraform_force_update_this_is_not_used"
    value = var.force_helm_update
  }

  depends_on = [
    kubernetes_cluster_role_binding.tiller_cluster_role,
    helm_release.cluster_monitoring,
  ]
}
