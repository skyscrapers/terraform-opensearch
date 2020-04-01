terraform {
  required_version = ">= 0.12.24"

  required_providers {
    aws        = ">= 2.55.0"
    helm       = ">= 1.1.1"
    kubernetes = ">= 1.11.1"
  }
}
