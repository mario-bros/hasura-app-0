# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  project = "hasura-trigger-function"
  region  = "asia-southeast2"
}

# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "hasura-trigger-function.appspot.com"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
