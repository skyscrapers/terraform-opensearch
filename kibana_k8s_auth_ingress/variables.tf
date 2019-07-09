variable "elasticsearch_endpoint" {
  type        = string
  description = "Endpoint of the AWS Elasticsearch domain"
}

variable "elasticsearch_domain_name" {
  type        = string
  description = "Domain name of the AWS Elasticsearch domain"
}

variable "kubernetes_namespace" {
  type        = string
  description = "Kubernetes namespace where to deploy the Ingress"
}

variable "ingress_host" {
  type        = string
  description = "Hostname to use for the Ingress"
}

variable "ingress_auth_url" {
  type        = string
  description = "Value to set for the `nginx.ingress.kubernetes.io/auth-url` annotation"
}

variable "ingress_auth_signin" {
  type        = string
  description = "Value to set for the `nginx.ingress.kubernetes.io/auth-signin` annotation"
}

variable "ingress_configuration_snippet" {
  type        = string
  description = "Value to set for the `nginx.ingress.kubernetes.io/configuration-snippet` annotation"
  default     = null
}
