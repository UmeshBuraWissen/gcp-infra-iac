module "cloudRun" {
  source     = "../../modules/cloudrun"
  for_each   = { for i in var.cloudrunsql_config : i.name => i }
  name       = each.value["name"]
  location   = each.value["location"]
  project_id = local.project.project_id
  envs       = each.value["envs"]
  template = {
    spec = {
      containers = {
        image = each.value.image
      }
    }
  }
  metadata = {
    annotations = {
      maxScale = each.value["maxScale"]
      #   connection_name = module.cloudSql[each.value["sql_name"]].connection_name
      client-name = each.value["client-name"]
    }
  }
  autogenerate_revision_name = each.value["autogenerate_revision_name"]
  timeout_seconds            = each.value["timeout_seconds"]
  service_account_name       = each.value["service_account_name"]
  #   depends_on                 = [module.cloudSql]

}
