resource "google_storage_bucket" "remote_state_storage" {
  name = module.naming.resource_name.remote_state_bucket

  project  = data.google_project.current.project_id
  location = "US"

  storage_class               = "MULTI_REGIONAL"
  uniform_bucket_level_access = true

  force_destroy = true
  versioning {
    enabled = true
  }

  labels = local.labels
}
