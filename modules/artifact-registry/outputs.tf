output "artifact_id" {
  description = "an identifier for the resource"
  value       = google_artifact_registry_repository.repo.id
}

output "artifact_name" {
  description = "an identifier for the resource"
  value       = google_artifact_registry_repository.repo.name
}
