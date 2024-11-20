locals {
  services = [
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "vpcaccess.googleapis.com",
    "file.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "cloudkms.googleapis.com",
    "osconfig.googleapis.com",
    "certificatemanager.googleapis.com",
    "cloudasset.googleapis.com",
    "iap.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudscheduler.googleapis.com",
    "servicehealth.googleapis.com",
    "containersecurity.googleapis.com",
    "networkmanagement.googleapis.com",
    "dataform.googleapis.com",
    "dataflow.googleapis.com",
    "datapipelines.googleapis.com",
  ]
}


resource "google_project_service" "project" {
  for_each = toset(local.services)

  project = local.project.project_id
  service = each.key

  disable_on_destroy         = true
  disable_dependent_services = true

  depends_on = [google_project.current]
}
