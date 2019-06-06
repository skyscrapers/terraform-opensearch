provider "helm" {
  version        = ">= 0.9"
  install_tiller = false

  kubernetes {
    config_context = var.kubernetes_context
  }
}

provider "kubernetes" {
  version        = ">= 1.7"
  config_context = var.kubernetes_context
}

locals {
  name = "kibana-gatekeeper"
}

resource "kubernetes_deployment" "gatekeeper" {
  metadata {
    name      = local.name
    namespace = var.kubernetes_namespace

    labels = {
      app = local.name
    }
  }

  spec {
    selector {
      match_labels = {
        app = local.name
      }
    }

    template {
      metadata {
        labels = {
          app = local.name
        }
      }

      spec {
        container {
          name  = local.name
          image = var.gatekeeper_image
          args  = concat([
            "--listen=0.0.0.0:3000"
            "--upstream-url=${var.gatekeeper_upstream_url}"
            "--discovery-url=${var.gatekeeper_discovery_url}"
            "--redirection-url=${var.gatekeeper_redirection_url}"
            "--client-id=${var.gatekeeper_client_id}"
            "--client-secret=${var.gatekeeper_client_secret}"
            "--enable-refresh-tokens=true"
            "--encryption-key=${random_string.encryption_key.result}"
            "--resources=uri=/*|groups=${var.gatekeeper_oidc_groups}"
            "--scopes=groups"
            "--upstream-keepalive-timeout=${var.gatekeeper_timeout}"
            "--upstream-timeout=${var.gatekeeper_timeout}"
            "--upstream-response-header-timeout=${var.gatekeeper_timeout}"
            "--server-read-timeout=${var.gatekeeper_timeout}"
            "--server-write-timeout=${var.gatekeeper_timeout}"
            "--enable-authorization-header=false"
          ], var.gatekeeper_extra_args)
        }

      }
    }
  }
}

resource "kubernetes_service" "gatekeeper" {
  metadata {
    name = local.name

    labels = {
      app = local.name
    }
  }

  spec {
    type = "ClusterIP"

    selector {
      app = local.name
    }

    port {
      port        = 3000
      target_port = 3000
    }
  }
}

resource "kubernetes_ingress" "gatekeeper" {
  metadata {
    name = local.name

    labels = {
      app = local.name
    }

    annotations = {
      kubernetes.io/ingress.class          = "nginx"
      kubernetes.io/tls-acme               = "true"
      nginx.ingress.kubernetes.io/app-root = "/_plugin/kibana/"
    }
  }

  spec {
    rule {
      host = var.gatekeeper_redirection_url

      http {
        path {
          backend {
            service_name = local.name
            service_port = 3000
          }

          path = "/"
        }
      }
    }

    tls {
      secret_name = "${local.name}-tls"
      hosts = var.gatekeeper_redirection_url
    }
  }
}
