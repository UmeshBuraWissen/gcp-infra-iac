locals {
  sequence = coalesce(var.sequence, "000")

  resource_key_google        = format("%s-%s-%s-%s%s", var.environment, local.gcp_regions[var.region].region_code, var.workload, var.identifier, local.sequence)
  resource_key_google_global = format("%s-%s-%s%s", var.environment, var.workload, var.identifier, local.sequence) # global name without region code

  resource = {
    google_project = join("", ["proj", "-", format("%s-%s%s", var.environment, var.workload, local.sequence)])

    remote_state_bucket = join("", ["buck-tf", "-", format("%s-%s%s", var.environment, var.workload, local.sequence)])

    google_service_account = join("", ["sera", "-", local.resource_key_google_global])

    google_artifact_registry_repository = join("", ["areg", "-", local.resource_key_google])
    google_compute_network              = join("", ["vpc", "-", local.resource_key_google])
    google_cloud_run                    = join("", ["crun", "-", local.resource_key_google])
    google_cloudbuild_trigger           = join("", ["gclbu", "-", local.resource_key_google])

    # google_app_engine               = join("", ["gapp", "-", local.resource_key_google])
    # google_bigquery_instance        = join("", ["bq", "-", local.resource_key_google])
    # google_bigtable_instance        = join("", ["bigtb", "-", local.resource_key_google])
    # google_cloud_function           = join("", ["cfun", "-", local.resource_key_google])
    # google_cloud_run                = join("", ["crun", "-", local.resource_key_google])
    # google_compute_engine           = join("", ["gce", "-", local.resource_key_google])
    # google_cloud_firewall           = join("", ["gcfw", "-", local.resource_key_google])
    # google_container_registry       = join("", ["gcr", "-", local.resource_key_google])
    # google_storage_bucket           = join("", ["gcs", "-", local.resource_key_google])
    # google_kubernetes_engine        = join("", ["gke", "-", local.resource_key_google])
    # google_compute_network          = join("", ["vpc", "-", local.resource_key_google])
    # google_cloud_pubsub             = join("", ["gpsb", "-", local.resource_key_google])
    # google_cloud_redis              = join("", ["gche", "-", local.resource_key_google])
    # google_secret_manager           = join("", ["gsm", "-", local.resource_key_google])
    # google_database_spanner         = join("", ["gspn", "-", local.resource_key_google])
    # google_sva_connector            = join("", ["gsva", "-", local.resource_key_google])
    # google_db_sql_instance          = join("", ["gsql", "-", local.resource_key_google])
    # google_dataproc_cluster         = join("", ["gdpc", "-", local.resource_key_google])
    # google_data_fusion              = join("", ["gdfu", "-", local.resource_key_google])
    # google_dataflow_job             = join("", ["gdfl", "-", local.resource_key_google])
    # google_composer_environment     = join("", ["gcmp", "-", local.resource_key_google])
    # google_data_catalog_entry_group = join("", ["gctg", "-", local.resource_key_google])
    # google_data_catalog_entry       = join("", ["gcat", "-", local.resource_key_google])
  }
}

output "resource_name" {
  value = local.resource
}

output "resource_key" {
  value = local.resource_key_google
}
