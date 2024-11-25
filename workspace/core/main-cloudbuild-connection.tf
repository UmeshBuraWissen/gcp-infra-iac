variable "github_pat" {
  type        = string
  sensitive   = true
  description = "Set this via CLI variable while running terraform apply"
}

# Create a secret containing the personal access token and grant permissions to the Service Agent
resource "google_secret_manager_secret" "github_token_secret" {
  project   = local.project.project_id
  secret_id = "GITHUB_PAT"

  replication {
    auto {}
  }
  depends_on = [google_project_service.project]
}

resource "google_secret_manager_secret_version" "github_token_secret_version" {
  secret      = google_secret_manager_secret.github_token_secret.id
  secret_data = var.github_pat

  lifecycle {
    # ignore_changes = [secret_data]
  }
}

data "google_iam_policy" "serviceagent_secret_accessor" {
  binding {
    role    = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:service-${local.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  project     = google_secret_manager_secret.github_token_secret.project
  secret_id   = google_secret_manager_secret.github_token_secret.secret_id
  policy_data = data.google_iam_policy.serviceagent_secret_accessor.policy_data
}

// Create the GitHub connection
resource "google_cloudbuildv2_connection" "github" {
  project  = local.project.project_id
  location = var.metadata.region
  name     = "github-connection"

  github_config {
    app_installation_id = var.github_application_id
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
    }
  }
  depends_on = [google_secret_manager_secret_iam_policy.policy, google_project_service.project]
}

output "github_connection" {
  value = google_cloudbuildv2_connection.github
}