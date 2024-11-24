# resource "google_secret_manager_secret" "github_app_id" {
#   secret_id = "github-app-id"
#   replication {
#     auto {}
#   }
# }

# resource "google_secret_manager_secret" "github_oauth_token" {
#   secret_id = "github-oauth-token"
#   replication {
#     auto {}
#   }
# }

# resource "google_secret_manager_secret_version" "github_app_id_version" {
#   secret      = google_secret_manager_secret.github_app_id.id
#   secret_data = "YOUR_GITHUB_APP_INSTALLATION_ID"
# }


# resource "google_secret_manager_secret_version" "github_oauth_token_version" {
#   secret      = google_secret_manager_secret.github_oauth_token.id
#   secret_data = "YOUR_GITHUB_OAUTH_TOKEN"
# }

resource "google_cloudbuildv2_connection" "github" {
  name     = "test"
  location = "us-central1"

  project = local.project.project_id

  github_config {
    app_installation_id = 57141306
    authorizer_credential {
      oauth_token_secret_version = "projects/proj-dev-demo000-gbjy/secrets/test-github-oauthtoken-1d8ff8/versions/latest" ## this is added manually
    }
  }
}


# import {
#   to = google_cloudbuildv2_connection.github
#   id = "projects/proj-dev-demo000-gbjy/locations/us-central1/connections/test"
# }


resource "google_cloudbuildv2_repository" "my-repository" {
  name     = "gcp-infra-iac"
  location = "us-central1"
  project  = local.project.project_id

  parent_connection = google_cloudbuildv2_connection.github.name
  remote_uri        = "https://github.com/UmeshBuraWissen/gcp-infra-iac.git"
}
