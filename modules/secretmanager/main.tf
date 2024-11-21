resource "google_secret_manager_secret" "secret-basic" {
  project   = var.project_id
  secret_id = var.secret_id #"secret-version"

  replication {
    user_managed {
      replicas {
        location = var.location
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret-version-deletion-policy" {
  secret = google_secret_manager_secret.secret-basic.id

  secret_data = var.secret_data #"secret-data"

}