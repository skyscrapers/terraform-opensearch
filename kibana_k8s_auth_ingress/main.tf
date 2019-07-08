provider "kubernetes" {
  version        = ">= 1.7"
  config_context = var.kubernetes_context
}

locals {
  app    = "kibana-ingress"
  domain = var.elasticsearch_domain_name
  name   = "${local.app}-${local.domain}"
}

resource "kubernetes_service" "kibana" {
  metadata {
    name      = local.name
    namespace = var.kubernetes_namespace

    labels = {
      app    = local.app
      domain = local.domain
    }
  }

  spec {
    type          = "ExternalName"
    external_name = var.elasticsearch_endpoint
  }
}

resource "kubernetes_ingress" "kibana" {
  metadata {
    name      = local.name
    namespace = var.kubernetes_namespace

    labels = {
      app    = local.app
      domain = local.domain
    }

    annotations = {
      "kubernetes.io/ingress.class"                       = "nginx",
      "kubernetes.io/tls-acme"                            = "true",
      "nginx.ingress.kubernetes.io/app-root"              = "/_plugin/kibana/",
      "nginx.ingress.kubernetes.io/backend-protocol"      = "HTTPS"
      "nginx.ingress.kubernetes.io/auth-url"              = var.ingress_auth_url,
      "nginx.ingress.kubernetes.io/auth-signin"           = var.ingress_auth_signin,
      "nginx.ingress.kubernetes.io/configuration-snippet" = var.ingress_configuration_snippet,
    }
  }

  spec {
    rule {
      host = var.ingress_host

      http {
        path {
          backend {
            service_name = local.name
          }

          path = "/"
        }
      }
    }

    tls {
      secret_name = "${local.name}-tls"
      hosts = [var.ingress_host]
    }
  }
}
