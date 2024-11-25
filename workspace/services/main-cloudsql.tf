resource "google_compute_global_address" "cloudsql" {
  name    = module.bootstrap.resource_name.google_compute_global_address
  project = local.project.project_id
  network = google_compute_network.vpc.id

  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
}

resource "google_service_networking_connection" "cloudql" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.cloudsql.name]
  deletion_policy         = "ABANDON"
}

resource "google_compute_network_peering_routes_config" "peering_routes" {
  project = local.project.project_id
  peering = google_service_networking_connection.cloudql.peering
  network = google_compute_network.vpc.name

  import_custom_routes = true
  export_custom_routes = true
}

module "cloudsql" {
  source = "../../modules/cloudsql"

  for_each = { for i, v in var.cloudsql : v.purpose => merge(v, { "index" = i }) }

  name = format("%s%s", module.bootstrap.resource_name.google_sql_database_instance, each.value.index + 1)

  project_id = local.project.project_id
  region     = var.metadata.region

  vpc_id = google_compute_network.vpc.id

  ipv4_enabled         = each.value.ipv4_enabled
  database_version     = each.value.database_version
  tier                 = each.value.tier
  backup_configuration = each.value.backup_configuration
  ssl_mode             = each.value.ssl_mode

  sql_user_name = each.value.sql_user_name
  sql_user_pass = each.value.sql_user_pass

  depends_on = [google_service_networking_connection.cloudql]
}

module "sql_username_secret" {
  source = "../../modules/secretmanager"

  project_id  = local.project.project_id
  secret_id   = "DB_USERNAME"
  location    = var.metadata.region
  secret_data = "admin"
}

module "sql_password_secret" {
  source = "../../modules/secretmanager"

  project_id  = local.project.project_id
  secret_id   = "DB_PASSWORD"
  location    = var.metadata.region
  secret_data = "securepassword"
}

output "cloudsql" {
  value     = module.cloudsql
  sensitive = true
}
