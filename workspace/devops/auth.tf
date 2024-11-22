terraform {
  backend "gcs" {
    bucket = "buck-tf-dev-demo000"
    prefix = "dev-usce1-demo-devops000"
  }

  required_providers {
    google = {
      version = "6.11.2"
    }
    google-beta = {
      version = "6.11.2"
    }
  }
}

provider "google" {
}

provider "google-beta" {
}
