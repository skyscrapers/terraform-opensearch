variable "elasticsearch_monitoring_chart_version" {
  type        = string
  description = "elasticsearch-monitoring Helm chart version to deploy"
  default     = "1.8.0"
}

variable "elasticsearch_endpoint" {
  type        = string
  description = "Endpoint of the AWS Elasticsearch domain"
}

variable "elasticsearch_domain_name" {
  type        = string
  description = "Domain name of the AWS Elasticsearch domain"
}

variable "elasticsearch_domain_region" {
  type        = string
  description = "Region of the AWS Elasticsearch domain"
}

variable "es_exporter_memory" {
  type        = string
  description = "Memory request and limit for the prometheus-elasticsearch-exporter pod"
  default     = "48Mi"
}

variable "kubernetes_namespace" {
  type        = string
  description = "Kubernetes namespace where to deploy the `skyscrapers/elasticsearch-monitoring` chart"
}

variable "irsa_enabled" {
  type        = bool
  description = "Whether to use [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html). When `true`, the Cloudwatch exporter's SA is appropriately annotated. If `false` a [kube2iam](https://github.com/jtblin/kube2iam) Pod annotation is set instead"
  default     = true
}

variable "cloudwatch_exporter_role_arn" {
  type        = string
  description = "IAM role ARN to use for the CloudWatch exporter. Used via either IRSA or kube2iam (see `var.irsa_enabled`)"
}

variable "cw_exporter_memory" {
  type        = string
  description = "Memory request and limit for the prometheus-cloudwatch-exporter pod"
  default     = "160Mi"
}

variable "force_helm_update" {
  type        = string
  description = "Modify this variable to trigger an update on all Helm charts (you can set any value). Due to current limitations of the Helm provider, it doesn't detect drift on the deployed values"
  default     = "1"
}

variable "sla" {
  type        = string
  description = "SLA of the monitored Elasticsearch cluster. Will default to the k8s cluster SLA if omited"
  default     = null
}
