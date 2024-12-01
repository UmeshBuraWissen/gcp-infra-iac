output "cloudsql" {
  value     = google_sql_database_instance.sql
  sensitive = true
}

output "connection_name" {
  value = google_sql_database_instance.sql.connection_name
}

output "private_ip_address" {
  value = google_sql_database_instance.sql.private_ip_address
}
