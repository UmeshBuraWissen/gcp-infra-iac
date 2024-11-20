module "naming" {
  source = "../../modules/naming"

  environment = var.environment
  region      = var.region
  workload    = var.workload
  identifier  = var.identifier
  sequence    = var.sequence
}

locals {
  backend = <<-EOT
      backend "gcs" {
          bucket = "${module.naming.resource_name.remote_state_bucket}"
          prefix = "${module.naming.resource_key}"
        }
  EOT
}

data "template_file" "auth" {
  vars = {
    backend = local.backend
    # project = module.naming.resource_name.google_project
  }
  template = file("${path.module}/auth.tf.tmpl")
}

resource "local_sensitive_file" "auth" {
  filename = "auth.tf"
  content  = data.template_file.auth.rendered
}

output "resource_key" {
  value = module.naming.resource_key
}

output "resource_name" {
  value = module.naming.resource_name
}
