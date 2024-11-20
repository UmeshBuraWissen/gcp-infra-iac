data "google_organization" "org" {
  organization = var.organization.id
  domain       = var.organization.domain
}

module "naming" {
  source = "../../modules/naming"

  environment = var.metadata.environment
  workload    = var.metadata.workload
  region      = var.metadata.region
  sequence    = var.metadata.sequence
}

locals {
  labels = {
    environment = var.metadata.environment
    workload    = var.metadata.workload
    region      = var.metadata.region
    sequence    = var.metadata.sequence
  }
}
