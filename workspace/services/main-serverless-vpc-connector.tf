resource "google_vpc_access_connector" "connector" {
  name          = "test-serverless-vpc"
  ip_cidr_range = "10.8.0.0/28"
  network       = "wissen-nodejs-app-gcp-vpc"
  min_instances = 2
  max_instances = 3
  machine_type  = "f1-micro"
  region        = var.metadata.region
  project       = local.project.project_id

  lifecycle {
    ignore_changes = [max_throughput, min_throughput]
  }
}

import {
  id = "projects/proj-dev-demo000-gbjy/locations/us-central1/connectors/test-serverless-vpc"
  to = google_vpc_access_connector.connector
}
