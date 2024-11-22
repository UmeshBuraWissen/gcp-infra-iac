module "cloud-build-trigger" {
  source = "../../modules/cloud-build-trigger"
  for_each = { for i in var.build_config : i.name => i }
  name = each.value["name"]
  project  =  each.value["project"]
  disabled = each.value["disabled"]
  path = each.value["path"]
  owner = each.value["owner"]
  github_reponame  = each.value["github_reponame"]
  branch       = each.value["branch"]
  invert_regex = each.value["invert_regex"]
  service_account = each.value["service_account"]
  _TFACTION = each.value["_TFACTION"]
}
