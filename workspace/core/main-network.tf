resource "google_compute_network" "vpc" {
  name = module.bootstrap.resource_name.google_compute_network

  project                 = local.project.project_id
  auto_create_subnetworks = true
}

output "vpc" {
  value = google_compute_network.vpc
}
