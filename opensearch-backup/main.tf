terraform {
  required_version = ">= 1.3.9, < 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.1"
    }
  }
}

## TODO: Keep outside module? Write docs
# provider "opensearch" {
#   url = var.opensearch_url
# }
