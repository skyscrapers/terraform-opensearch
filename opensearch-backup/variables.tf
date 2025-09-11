variable "name" {
  description = "Name for the snapshot system, S3 bucket, etc."
  type        = string
}

variable "opensearch_endpoint" {
  description = "Endpoint of the OpenSearch domain (including https://)"
  type        = string
}

variable "aws_kms_key_arn" {
  description = "ARN of the CMK used for S3 Server Side Encryption. When specified, we'll use the `aws:kms` SSE algorithm. When not specified, falls back to using `AES256`"
  type        = string
  default     = null
}

variable "create_cron_expression" {
  description = "The cron schedule used to create snapshots"
  type        = string
  default     = "0 0 * * *"
}

variable "create_time_limit" {
  description = "Sets the maximum time to wait for snapshot creation to finish. If time_limit is longer than the scheduled time interval for taking snapshots, no scheduled snapshots are taken until time_limit elapses. For example, if time_limit is set to 35 minutes and snapshots are taken every 30 minutes starting at midnight, the snapshots at 00:00 and 01:00 are taken, but the snapshot at 00:30 is skipped"
  type        = string
  default     = "1h"
}

variable "delete_cron_expression" {
  description = "The cron schedule used to delete snapshots"
  type        = string
  default     = "0 2 * * *"
}

variable "delete_time_limit" {
  description = "Sets the maximum time to wait for snapshot deletion to finish"
  type        = string
  default     = "1h"
}

variable "max_age" {
  description = "The maximum time a snapshot is retained in S3"
  type        = string
  default     = "14d"
}

variable "max_count" {
  description = "The maximum number of snapshots retained in S3"
  type        = number
  default     = 400
}

variable "min_count" {
  description = "The minimum number of snapshot retained in S3"
  type        = number
  default     = 1
}

variable "indices" {
  description = "The names of the indexes in the snapshot. Multiple index names are separated by `,`. Supports wildcards (`*`)"
  type        = string
  default     = "*"
}

variable "custom_sm_policy" {
  description = "Set this variable when you want to override the generated SM policy JSON with your own. Make sure to correctly set `snapshot_config.repository` to the same value as `var.name` (the bucket name)"
  type        = string
  default     = null
}

variable "s3_force_destroy" {
  description = "Whether to force-destroy and empty the S3 bucket when destroying this Terraform module. WARNING: Not recommended!"
  type        = bool
  default     = false
}

variable "s3_replication_configuration" {
  description = "Replication configuration block for the S3 bucket. See <https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/v3.15.1/examples/s3-replication> for an example"
  type        = any
  default     = {}
}

variable "monitoring_enabled" {
  description = "Whether to deploy a small [elasticsearch-exporter](https://github.com/prometheus-community/elasticsearch_exporter) with [PrometheusRule](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1.PrometheusRule) for monitoring the snapshots. Requires the [prometheus-operator](https://prometheus-operator.dev/) to be deployed"
  type        = bool
  default     = true
}

variable "monitoring_elasticsearch_exporter_version" {
  description = "Version of the prometheus-elasticsearch-exporter Helm chart to deploy"
  type        = string
  default     = "7.0.0"
}

variable "monitoring_elasticsearch_exporter_tolerations" {
  type        = any
  description = "Tolerations to add to the kubernetes pods. Set to null to disable."
  default = {
    tolerations = [{
      key      = "role"
      operator = "Equal"
      value    = "system"
      effect   = "NoSchedule"
    }]
  }
}

variable "monitoring_elasticsearch_exporter_nodeSelector" {
  description = "nodeSelector to add to the kubernetes pods. Set to null to disable."
  type        = map(map(string))
  default = {
    nodeSelector = {
      role = "system"
    }
  }
}

variable "monitoring_namespace" {
  description = "Namespace where to deploy the PrometheusRule"
  type        = string
  default     = "infrastructure"
}

variable "monitoring_prometheus_labels" {
  description = "Additional K8s labels to add to the ServiceMonitor and PrometheusRule"
  type        = map(string)
  default     = { prometheus = "opensearch-backup" }
}

variable "monitoring_prometheusrule_alert_labels" {
  description = "Additional labels to add to the PrometheusRule alert"
  type        = map(string)
  default     = {}
}

variable "monitoring_prometheusrule_query_period" {
  description = "Period to apply to the PrometheusRule queries. Make sure this is bigger than the `create_cron_expression` interval"
  type        = string
  default     = "32h"
}

variable "monitoring_prometheusrule_severity" {
  description = "Severity of the PrometheusRule alert. Usual values are: `info`, `warning` and `critical`"
  type        = string
  default     = "warning"
}

variable "extra_bucket_policy" {
  description = "Extra bucket policy to attach to the S3 bucket (JSON string formatted)"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether to use Amazon S3 Bucket Keys for encryption, which reduces API costs"
  type        = bool
  default     = false
}
