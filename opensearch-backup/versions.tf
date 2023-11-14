terraform {
  required_version = ">= 1.3.9, < 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.1" # TODO update once SM support has been merged & released
    }
  }
}
