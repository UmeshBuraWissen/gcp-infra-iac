resource "google_sql_database_instance" "sql" {
  project          = var.project_id
  name             = var.name
  region           = var.region
  database_version = var.database_version
  settings {
    tier = var.tier

    dynamic "backup_configuration" {
      for_each = var.backup_configuration != null ? [1] : []
      content {
        enabled            = true
        binary_log_enabled = var.backup_configuration.binary_log_enabled
        location           = var.backup_configuration.location
      }
    }

    ip_configuration {
      ipv4_enabled    = var.ipv4_enabled
      private_network = var.vpc_id
      ssl_mode        = var.ssl_mode
      # require_ssl = var.require_ssl
    }
  }

  deletion_protection = var.deletion_protection
}

resource "google_sql_user" "admin" {
  project  = var.project_id
  name     = var.sql_user_name
  password = var.sql_user_pass
  instance = google_sql_database_instance.sql.name
}

