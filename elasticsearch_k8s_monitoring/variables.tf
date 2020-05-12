variable "elasticsearch_monitoring_chart_version" {
  type        = string
  description = "elasticsearch-monitoring Helm chart version to deploy"
  default     = "1.1.0"
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

variable "kubernetes_namespace" {
  type        = string
  description = "Kubernetes namespace where to deploy the `skyscrapers/elasticsearch-monitoring` chart"
}

variable "kubernetes_worker_instance_role_arns" {
  type        = list(string)
  description = "Role ARNs of the Kubernetes nodes to attach the kube2iam assume_role to"
}

variable "force_helm_update" {
  type        = string
  description = "Modify this variable to trigger an update on all Helm charts (you can set any value). Due to current limitations of the Helm provider, it doesn't detect drift on the deployed values"
  default     = "1"
}
