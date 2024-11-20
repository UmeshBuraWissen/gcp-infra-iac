terraform {
  #   backend "gcs" {
  #   }

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
