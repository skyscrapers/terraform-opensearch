locals {
  elasticsearch_endpoint = "https://${element(concat(aws_elasticsearch_domain.es.*.endpoint, aws_elasticsearch_domain.public_es.*.endpoint), 0)}"
}

data "aws_region" "current" {}

data "template_file" "helm_values" {
  count    = "${length(var.prometheus_labels) != 0 ? 1 : 0}"
  template = "${file("${path.module}/templates/helm-values.tpl.yaml")}"

  vars {
    elasticsearch_endpoint   = "${local.elasticsearch_endpoint}"
    prometheus_labels        = "${indent(4, join("\n", data.template_file.prometheus_kv_mapping.*.rendered))}"
    cloudwatch_exporter_role = "${aws_iam_role.cloudwatch_exporter.arn}"
    region                   = "${data.aws_region.current.name}"
    elasticsearch_domain     = "${element(concat(aws_elasticsearch_domain.es.*.domain_name, aws_elasticsearch_domain.public_es.*.domain_name), 0)}"
  }
}

data "template_file" "prometheus_kv_mapping" {
  count    = "${length(var.prometheus_labels)}"
  template = "$${key}: $${value}"

  vars {
    key   = "${element(keys(var.prometheus_labels), count.index)}"
    value = "${element(values(var.prometheus_labels), count.index)}"
  }
}

resource "local_file" "helm_values_file" {
  count    = "${length(var.prometheus_labels) != 0 ? 1 : 0}"
  content  = "${data.template_file.helm_values.rendered}"
  # The file needs to be in the same folder as the TF code calling this module.
  filename = "helm-values.yaml"
}
