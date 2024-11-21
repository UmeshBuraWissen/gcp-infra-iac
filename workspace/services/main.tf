data "google_organization" "org" {
  organization = var.organization.id
  domain       = var.organization.domain
}

data "google_client_config" "current" {}

data "google_project" "current" {
  project_id = coalesce(var.project_id, module.naming.resource_name.google_project)
}

locals {
  project = data.google_project.current
}

module "naming" {
  source = "../../modules/naming"

  environment = var.metadata.environment
  workload    = var.metadata.workload
  region      = var.metadata.region
  sequence    = var.metadata.sequence
  identifier  = var.metadata.identifier
}

locals {
  labels = {
    environment = var.metadata.environment
    workload    = var.metadata.workload
    region      = var.metadata.region
    sequence    = var.metadata.sequence
    identifier  = var.metadata.identifier
  }
}

module "bootstrap" {
  source = "../../modules/bootstrap"

  environment = var.metadata.environment
  workload    = var.metadata.workload
  region      = var.metadata.region
  sequence    = var.metadata.sequence
  identifier  = var.metadata.identifier
}
