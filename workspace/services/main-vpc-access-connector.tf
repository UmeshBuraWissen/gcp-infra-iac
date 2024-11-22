resource "google_vpc_access_connector" "connector" {
  name = format("%s%s", module.bootstrap.resource_name.google_vpc_access_connector, "1")

  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.name

  min_instances = 2
  max_instances = 3
  machine_type  = "f1-micro"
  region        = var.metadata.region
  project       = local.project.project_id

  lifecycle {
    ignore_changes = [max_throughput, min_throughput]
  }
}
