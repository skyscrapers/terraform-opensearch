variable "elasticsearch_endpoint" {
  type        = string
  description = "Endpoint of the AWS Elasticsearch domain"
}

variable "kubernetes_context" {
  type        = string
  description = "Kubeconfig context to use for deploying the `skyscrapers/elasticsearch-monitoring` chart"
}

variable "kubernetes_namespace" {
  type        = string
  description = "Kubernetes namespace where to deploy the `skyscrapers/elasticsearch-monitoring` chart"
}

variable "gatekeeper_oidc_groups" {
  #type        = list(string)
  description = "Groups that will be granted access to the Kibana dashboard. When using Dex and Kubesignin these will be GitHub teams in the form `<gh_org>:<gh_team>`, for example `skyscrapers:k8s-admins`"
  default     = []
}


          #   "--upstream-url=${var.gatekeeper_upstream_url}"
          #   "--discovery-url=${var.gatekeeper_discovery_url}"
          #   "--redirection-url=${var.gatekeeper_redirection_url}"
          #   "--client-id=${var.gatekeeper_client_id}"
          #   "--client-secret=${var.gatekeeper_client_secret}"
          #   "--enable-refresh-tokens=true"
          #   "--encryption-key=${random_string.encryption_key.result}"
          #   "--resources=uri=/*|groups=${var.gatekeeper_oidc_groups}"
          #   "--scopes=groups"
          #   "--upstream-keepalive-timeout=${var.gatekeeper_timeout}"
          #   "--upstream-timeout=${var.gatekeeper_timeout}"
          #   "--upstream-response-header-timeout=${var.gatekeeper_timeout}"
          #   "--server-read-timeout=${var.gatekeeper_timeout}"
          #   "--server-write-timeout=${var.gatekeeper_timeout}"
          #   "--enable-authorization-header=false"
          # ], var.gatekeeper_extra_args)
