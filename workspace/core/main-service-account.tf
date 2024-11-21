resource "google_service_account" "project" {
  account_id   = module.bootstrap.resource_name.google_service_account
  display_name = "Project Service Account"
  project      = local.project.project_id
}

output "project_sa" {
  value = google_service_account.project
}


locals {
  project_sa_roles = ["roles/editor"]
}

resource "google_project_iam_member" "project_sa_roles" {
  for_each = toset(local.project_sa_roles)

  project = local.project.project_id
  role    = each.value
  member  = format("serviceAccount:%s", google_service_account.project.email)

  depends_on = [data.google_project.current]
}
