locals {
  services = [
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudasset.googleapis.com",
    "sqladmin.googleapis.com",
    "servicehealth.googleapis.com",
    "networkmanagement.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

resource "google_project_service" "project" {
  for_each = toset(local.services)

  project = local.project.project_id
  service = each.key

  disable_on_destroy         = true
  disable_dependent_services = true
}
