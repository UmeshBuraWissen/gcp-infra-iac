resource "random_string" "unique_suffix" {
  length  = 4
  upper   = false
  special = false
  numeric = false
}

resource "google_project" "current" {
  name = module.naming.resource_name.google_project

  project_id = format("%s-%s", module.naming.resource_name.google_project, random_string.unique_suffix.result)
  org_id     = data.google_organization.org.org_id

  deletion_policy = "DELETE"
  labels          = local.labels
}

output "project" {
  value = google_project.current
}
