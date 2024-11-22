resource "google_compute_network" "vpc" {
  name = module.bootstrap.resource_name.google_compute_network

  project                 = local.project.project_id
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "deny_all_ingress" {
  project = local.project.project_id
  name    = "deny-all-ingress"
  network = google_compute_network.vpc.name

  deny {
    protocol = "all"
  }

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_3306_ingress" {
  project = local.project.project_id

  name    = "allow-mysql-port-3306"
  network = google_compute_network.vpc.name

  source_ranges = ["10.8.0.0/28"] ## VPC connector subnet

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
}
