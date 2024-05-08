locals {
  app    = "kibana-gatekeeper"
  domain = var.elasticsearch_domain_name
  name   = "${local.app}-${local.domain}"
}

resource "random_string" "encryption_key" {
  length  = 32
  special = false
}

resource "kubernetes_deployment" "gatekeeper" {
  metadata {
    name      = local.name
    namespace = var.kubernetes_namespace

    labels = {
      app    = local.app
      domain = local.domain
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app    = local.app
        domain = local.domain
      }
    }

    template {
      metadata {
        labels = {
          app    = local.app
          domain = local.domain
        }
      }

      spec {
        container {
          name  = "gatekeeper"
          image = var.gatekeeper_image
          args = concat([
            "--listen=0.0.0.0:3000",
            "--discovery-url=${var.gatekeeper_discovery_url}",
            "--client-id=${var.gatekeeper_client_id}",
            "--client-secret=${var.gatekeeper_client_secret}",
            "--upstream-url=https://${var.elasticsearch_endpoint}",
            "--redirection-url=https://${var.gatekeeper_ingress_host}",
            "--enable-refresh-tokens=true",
            "--encryption-key=${random_string.encryption_key.result}",
            "--resources=uri=/*|groups=${join(",", var.gatekeeper_oidc_groups)}",
            "--scopes=groups",
            "--upstream-keepalive-timeout=${var.gatekeeper_timeout}",
            "--upstream-timeout=${var.gatekeeper_timeout}",
            "--upstream-response-header-timeout=${var.gatekeeper_timeout}",
            "--server-read-timeout=${var.gatekeeper_timeout}",
            "--server-write-timeout=${var.gatekeeper_timeout}",
            "--enable-authorization-header=false"
          ], var.gatekeeper_extra_args)

          resources {
            limits {
              memory = "32Mi"
            }
            requests {
              cpu    = "1m"
              memory = "32Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/oauth/health"
              port = 3000
            }

            initial_delay_seconds = 3
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 3
            success_threshold     = 1
          }

          readiness_probe {
            http_get {
              path = "/oauth/health"
              port = 3000
            }

            initial_delay_seconds = 3
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 3
            success_threshold     = 1
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "gatekeeper" {
  metadata {
    name      = local.name
    namespace = var.kubernetes_namespace

    labels = {
      app    = local.app
      domain = local.domain
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app    = local.app
      domain = local.domain
    }

    port {
      port        = 3000
      target_port = 3000
    }
  }
}

resource "kubernetes_ingress" "gatekeeper" {
  metadata {
    name      = local.name
    namespace = var.kubernetes_namespace

    labels = {
      app    = local.app
      domain = local.domain
    }

    annotations = {
      "kubernetes.io/ingress.class"          = "nginx",
      "kubernetes.io/tls-acme"               = "true",
      "nginx.ingress.kubernetes.io/app-root" = "/_plugin/kibana/",
    }
  }

  spec {
    rule {
      host = var.gatekeeper_ingress_host

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
      hosts       = [var.gatekeeper_ingress_host]
    }
  }
}
