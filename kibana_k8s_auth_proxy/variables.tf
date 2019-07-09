variable "elasticsearch_endpoint" {
  type        = string
  description = "Endpoint of the AWS Elasticsearch domain"
}

variable "elasticsearch_domain_name" {
  type        = string
  description = "Domain name of the AWS Elasticsearch domain"
}

variable "kubernetes_context" {
  type        = string
  description = "Kubeconfig context to use for deploying the Keycloack-gatekeeper proxy"
}

variable "kubernetes_namespace" {
  type        = string
  description = "Kubernetes namespace where to deploy the Keycloack-gatekeeper proxy"
}

variable "gatekeeper_image" {
  type        = string
  description = "Docker image to use for the Keycloack-gatekeeper deployment"
  default     = "keycloak/keycloak-gatekeeper:6.0.1"
}

variable "gatekeeper_ingress_host" {
  type        = string
  description = "Hostname to use for the Ingress"
}

variable "gatekeeper_discovery_url" {
  type        = string
  description = "URL for OpenID autoconfiguration"
}

variable "gatekeeper_client_id" {
  type        = string
  description = "Client ID for OpenID server"
}

variable "gatekeeper_client_secret" {
  type        = string
  description = "Client secret for OpenID server"
}

variable "gatekeeper_oidc_groups" {
  type        = list(string)
  description = "Groups that will be granted access. When using Dex with GitHub, teams are defined in the form `<gh_org>:<gh_team>`, for example `skyscrapers:k8s-admins`"
}

variable "gatekeeper_timeout" {
  type        = string
  description = "Upstream timeouts to use for the proxy"
  default     = "500s"
}

variable "gatekeeper_extra_args" {
  type        = list(string)
  description = "Additional keycloack-gatekeeper command line arguments"
  default     = []
}
