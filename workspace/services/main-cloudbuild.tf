resource "google_cloudbuildv2_repository" "iac_repo" {
  name       = var.app_build_config.repo_name
  remote_uri = var.app_build_config.repo_url

  parent_connection = local.o["core"]["github_connection"].name

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
    _ARTIFACT_REGISTRY = local.o["core"]["artifact_registry"].name,
    _REGION            = var.metadata.region,
    _CLOUD_RUN_SERVICE = module.cloud_run_services.cloud_run["nodejs_demo_app"].name
    _LOG_BUCKET        = local.o["core"]["log_bucket"].name
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
