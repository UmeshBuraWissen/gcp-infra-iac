resource "google_cloudbuildv2_repository" "iac_repo" {
  name       = var.app_build_config.repo_name
  remote_uri = var.app_build_config.repo_url

  parent_connection = google_cloudbuildv2_connection.github.name

  location = var.metadata.region
  project  = local.project.project_id

  #depends_on = [google_project_service.project]
}

resource "google_cloudbuild_trigger" "iac" {
  name     = var.app_build_config.build_name
  location = var.metadata.region

  project  = local.project.project_id
  disabled = false
  source_to_build {
    repo_type  = "GITHUB"
    ref        = var.app_build_config.ref
    repository = google_cloudbuildv2_repository.app_repo.id
  }

  substitutions = {
    _PROJECT_ID        = local.project.project_id,
    _ARTIFACT_REGISTRY = "areg-dev-usce1-demo-core000",
    _REGION            = var.metadata.region,
    _CLOUD_RUN_SERVICE = "nodejs_demo_app"

  }

  git_file_source {
    path       = var.app_build_config.filename
    repository = google_cloudbuildv2_repository.app_repo.id
    revision   = var.app_build_config.ref
    repo_type  = "GITHUB"
  }

  service_account = google_service_account.project.id

  depends_on = [module.cloud_run_services]
}
