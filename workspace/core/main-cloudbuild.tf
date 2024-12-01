resource "google_cloudbuildv2_repository" "iac_repo" {
  name       = var.iac_build_config.repo_name
  remote_uri = var.iac_build_config.repo_url

  parent_connection = google_cloudbuildv2_connection.github.name

  location = var.metadata.region
  project  = local.project.project_id

  depends_on = [google_project_service.project]
}

resource "google_cloudbuild_trigger" "iac" {
  name     = var.iac_build_config.build_name
  location = var.metadata.region

  project  = local.project.project_id
  disabled = false
  source_to_build {
    repo_type  = "GITHUB"
    ref        = var.iac_build_config.ref
    repository = google_cloudbuildv2_repository.iac_repo.id
  }

  substitutions = {
    _TFACTION   = "apply"
    _PROJECT_ID = local.project.project_id
    _LOG_BUCKET = google_storage_bucket.log_bucket.name
  }

  git_file_source {
    path       = var.iac_build_config.filename
    repository = google_cloudbuildv2_repository.iac_repo.id
    revision   = var.iac_build_config.ref
    repo_type  = "GITHUB"
  }

  service_account = google_service_account.project.id

  depends_on = [google_project_service.project]
}
