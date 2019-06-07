output "callback_uri" {
  description = "Callback URI. You might need to register this to your OIDC provider (like CoreOS Dex)"
  value       = "https://${var.gatekeeper_ingress_host}/oauth/callback"
}
