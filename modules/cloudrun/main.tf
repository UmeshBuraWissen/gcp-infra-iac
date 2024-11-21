resource "google_cloud_run_service" "default" {
  name     = var.name
  location = var.location
  project  = var.project_id
  template {
    spec {
      service_account_name = var.service_account_name
      containers {
        image = var.template.spec.containers.image
        dynamic "env" {
          for_each = var.envs
          content {
            name  = env.key
            value = env.value
          }

        }
        ports {
          container_port = 3000
        }
      }
    }

    metadata {
      annotations = {

        "autoscaling.knative.dev/maxScale"        = var.metadata.annotations.maxScale
        "run.googleapis.com/cloudsql-instances"   = var.metadata.annotations.connection_name
        "run.googleapis.com/client-name"          = var.metadata.annotations.client-name
        "run.googleapis.com/startup-cpu-boost"    = false
        "run.googleapis.com/vpc-access-connector" = var.metadata.annotations.vpc_access_conector
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
        # "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.name
        timeout_seconds = var.timeout_seconds
      }
    }


  }

  autogenerate_revision_name = var.autogenerate_revision_name
  # metadata {
  #   labels = {
  #     "revision-trigger" = timestamp() # This label forces a new revision to ensure the latest image is used
  #   }
  # }

  lifecycle {
    ignore_changes = [template[0].spec[0].containers[0].image]
  }
}
data "google_iam_policy" "noauth" {

  binding {
    role    = "roles/run.invoker"
    members = ["allUsers", ]
  }
}
resource "google_cloud_run_service_iam_policy" "noauth" {
  service     = google_cloud_run_service.default.name
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  policy_data = data.google_iam_policy.noauth.policy_data
  depends_on  = [google_cloud_run_service.default]
}
