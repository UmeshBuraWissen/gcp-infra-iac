data "google_project" "current" {
  project_id = coalesce(var.project_id, module.naming.resource_name.google_project)
}

locals {
  project = data.google_project.current
}

resource "google_project_iam_audit_config" "current" {
  project = data.google_project.current.id
  service = "allServices"
  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

output "project" {
  value = google_project.current
}
