module "cloud_run_services" {
  source = "../../modules/cloudrun"

  for_each = { for i, v in var.cloud_run_services : v.name => merge(v, { "index" = i }) }

  name = format("%s%s", module.bootstrap.resource_name.google_cloud_run, each.value.index + 1)

  location   = var.metadata.region
  project_id = local.project.project_id

  service_account_name = google_service_account.application_sa.email

  vpc_access_connector = google_vpc_access_connector.connector.name

  image          = each.value.image
  container_port = each.value.container_port

  env_vars = merge(each.value.env_vars, {
    "port"             = each.value.container_port
    "projectid"        = local.project.number
    "dbconnectionname" = try(module.cloudsql[each.value.cloudsql].private_ip_address, "")
    }
  )

  template_annotations = merge(each.value.template_annotations, {
    "autoscaling.knative.dev/maxScale"      = each.value.max_scale
    "run.googleapis.com/cloudsql-instances" = try(module.cloudsql[each.value.cloudsql].connection_name, "") ## db connection name
    "run.googleapis.com/startup-cpu-boost"  = false
    "timeout_seconds"                       = "6000"
  })
  autogenerate_revision_name = each.value.autogenerate_revision_name

  depends_on = [module.cloudsql]
}

output "cloud_run_services" {
  value = { for key, crun in module.cloud_run_services : key => crun.name }
}
