output "cloud_run" {
  value = google_cloud_run_service.cloud_run
}

output "name" {
  value = google_cloud_run_service.cloud_run.name
}
