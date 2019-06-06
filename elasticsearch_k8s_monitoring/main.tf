provider "helm" {
  version        = ">= 0.9"
  install_tiller = false

  kubernetes {
    config_context = var.kubernetes_context
  }
}

locals {
  elasticsearch_domain_endpoint = "https://${var.elasticsearch_domain_name}:443"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "cloudwatch_exporter_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "AWS"

      identifiers = var.kubernetes_worker_instance_role_arns
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
  name               = "${var.elasticsearch_domain_name}_elasticsearch_monitoring"
  path               = "/kube2iam/"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_exporter_assume.json
}

resource "aws_iam_role_policy" "cloudwatch_exporter" {
  role   = aws_iam_role.cloudwatch_exporter.id
  policy = data.aws_iam_policy_document.cloudwatch_exporter.json
}

data "template_file" "elasticsearch_monitoring_helm_values" {
  template = file("${path.module}/templates/elasticsearch-monitoring-values.yaml.tpl")

  vars = {
    elasticsearch_endpoint   = local.elasticsearch_domain_endpoint
    cloudwatch_exporter_role = aws_iam_role.cloudwatch_exporter.arn
    region                   = var.elasticsearch_domain_region
    elasticsearch_domain     = var.elasticsearch_domain_name
  }
}

resource "helm_release" "elasticsearch_monitoring" {
  name       = "logging-es-monitor"
  repository = "https://skyscrapers.github.io/charts"
  chart      = "elasticsearch-monitoring"
  version    = var.elasticsearch_monitoring_chart_version
  namespace  = var.kubernetes_namespace

  values = [
    data.template_file.elasticsearch_monitoring_helm_values.rendered,
  ]

  set_string {
    name  = "terraform_force_update_this_is_not_used"
    value = var.force_helm_update
  }
}
