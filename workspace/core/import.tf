module "import_naming" {
  for_each = { for import in var.import_state : import.identifier => import }

  source = "../../modules/naming"

  environment = each.value.environment
  workload    = each.value.workload
  region      = each.value.region
  sequence    = each.value.sequence
  identifier  = each.value.identifier
}

data "terraform_remote_state" "import" {
  for_each = module.import_naming

  backend = "gcs"

  config = {
    bucket = each.value.resource_name.remote_state_bucket
    prefix = each.value.resource_key
  }
}

locals {
  o = { for key, state in data.terraform_remote_state.import : key => state.outputs }
}
