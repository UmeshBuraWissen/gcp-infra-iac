resource "google_compute_firewall" "default" {
  name    = "allow-mysql-port-3306"
  network = "wissen-nodejs-app-gcp-vpc"

  source_ranges = ["10.8.0.0/28"]
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
}

import {
  id = "projects/proj-dev-demo000-gbjy/global/firewalls/allow-mysql-port-3306"
  to = google_compute_firewall.default
}