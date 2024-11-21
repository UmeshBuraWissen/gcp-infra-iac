resource "google_project" "current" {
  name = module.naming.resource_name.google_project

  project_id      = coalesce(var.project_id, module.naming.resource_name.google_project)
  org_id          = data.google_organization.org.org_id
  billing_account = var.organization.billing_account

  deletion_policy = "DELETE"
  labels          = local.labels
}

data "google_project" "current" {
  project_id = coalesce(var.project_id, module.naming.resource_name.google_project)
}

locals {
  project = data.google_project.current
}

import {
  to = google_project.current
  id = format("projects/%s", var.project_id)
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
