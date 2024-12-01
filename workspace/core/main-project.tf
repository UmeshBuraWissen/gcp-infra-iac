variable "project_id" {
  type        = string
  default     = null
  description = "Set this via CLI variable while running terraform apply"
}

data "google_project" "current" {
  project_id = var.project_id
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
  value = local.project
}
