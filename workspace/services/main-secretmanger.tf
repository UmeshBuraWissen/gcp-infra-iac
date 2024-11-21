module "secretmanger" {
  source      = "../../modules/secretmanager"
  for_each    = { for i in var.secretmanger_config : i.secret_id => i }
  project_id  = local.project.project_id
  secret_id   = each.value["secret_id"] #var.secret_id
  location    = var.metadata.region
  secret_data = each.value["secret_data"] #var.secret_data
}

