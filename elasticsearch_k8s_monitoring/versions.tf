terraform {
  required_version = "~> 1.0"

  required_providers {
    aws        = "~> 4.0"
    helm       = "~> 2.5"
    kubernetes = "~> 2.11"
  }
}
