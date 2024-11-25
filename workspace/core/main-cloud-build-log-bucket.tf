resource "google_storage_bucket" "log_bucket" {
  #   name = format("%s%s", module.naming.resource_name.remote_state_bucket, "1")
  name     = "cloud-build-logs-gbjy"
  project  = data.google_project.current.project_id
  location = var.metadata.region

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  force_destroy = true

  labels = local.labels
}
