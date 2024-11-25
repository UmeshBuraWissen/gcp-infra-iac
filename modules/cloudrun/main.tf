resource "google_cloud_run_service" "cloud_run" {
  name     = var.name
  location = var.location
  project  = var.project_id

  template {
    spec {
      service_account_name = var.service_account_name
      containers {
        image = var.image

        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }
        ports {
          container_port = var.container_port
        }
      }
    }

    metadata {
      annotations = merge(var.template_annotations,
        var.vpc_access_connector != null ? {
          "run.googleapis.com/vpc-access-connector" = var.vpc_access_connector
          "run.googleapis.com/vpc-access-egress"    = "all-traffic"
      } : {})
    }
  }

  autogenerate_revision_name = var.autogenerate_revision_name

  lifecycle {
    ignore_changes = [template[0].spec[0].containers[0].image, template[0].metadata[0].annotations]
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers", ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  service     = google_cloud_run_service.cloud_run.name
  location    = google_cloud_run_service.cloud_run.location
  project     = google_cloud_run_service.cloud_run.project
  policy_data = data.google_iam_policy.noauth.policy_data
  depends_on  = [google_cloud_run_service.cloud_run]
}
