resource "google_compute_network" "vpc" {
  name = module.bootstrap.resource_name.google_compute_network

  project                 = local.project.project_id
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "deny_all_ingress" {
  name = format("%s-%s", google_compute_network.vpc.name, "deny-all-ingress")

  project = local.project.project_id
  network = google_compute_network.vpc.name

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  priority      = 1000
}

resource "google_compute_firewall" "allow_3306_ingress" {
  name = format("%s-%s", google_compute_network.vpc.name, "allow-mysql-port-3306")

  project = local.project.project_id
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = [google_vpc_access_connector.connector.ip_cidr_range] ## VPC connector subnet
  direction     = "INGRESS"
  priority      = 100
}
