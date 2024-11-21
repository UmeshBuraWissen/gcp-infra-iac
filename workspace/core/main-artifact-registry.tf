module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id    = local.project.project_id
  location      = "us"
  format        = "DOCKER"
  repository_id = module.bootstrap.resource_name.google_artifact_registry_repository

  labels = local.labels

  depends_on = [google_project_service.project]
}

output "artifact_registry" {
  value = module.artifact_registry
}
