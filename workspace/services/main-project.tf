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

output "project" {
  value = local.project
}
