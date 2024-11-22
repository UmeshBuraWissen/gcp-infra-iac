resource "google_service_account" "application_sa" {
  account_id   = module.bootstrap.resource_name.google_service_account
  display_name = "Application Service Account"
  project      = local.project.project_id
}

output "application_sa" {
  value = google_service_account.application_sa
}


locals {
  application_sa_roles = ["roles/editor", "roles/secretmanager.admin"]
}

resource "google_project_iam_member" "application_sa_roles" {
  for_each = toset(local.application_sa_roles)

  project = local.project.project_id
  role    = each.value
  member  = format("serviceAccount:%s", google_service_account.application_sa.email)
}
