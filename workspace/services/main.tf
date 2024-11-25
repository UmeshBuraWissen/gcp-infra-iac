data "google_client_config" "current" {}

data "google_project" "current" {
  project_id = coalesce(var.project_id, local.o["core"]["project"].id)
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
