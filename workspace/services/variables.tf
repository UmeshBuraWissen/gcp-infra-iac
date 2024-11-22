variable "organization" {
  type = object({
    domain          = string
    id              = optional(string)
    billing_account = string
  })

  default = {
    domain          = "wissen.com"
    billing_account = "01CE4F-F5D80F-4EF741"
  }
}

variable "project_id" {
  type    = string
  default = "proj-dev-demo000-gbjy"
}

variable "metadata" {
  type = object({
    workload    = string
    sequence    = string
    environment = string
    region      = string
    identifier  = string
  })
}

variable "cloudsql" {
  type = list(object({
    purpose          = string
    database_version = string,
    tier             = string,
    backup_configuration = optional(object({
      binary_log_enabled = bool
      location           = string
    }))
    ipv4_enabled        = bool,
    ssl_mode            = string,
    deletion_protection = bool,
    sql_user_name       = string,
    sql_user_pass       = string
    })
  )
}

variable "cloud_run_services" {
  description = "A map of Cloud Run service configurations"
  type = list(object({
    name                       = string
    image                      = string
    env_vars                   = map(string)
    container_port             = number
    max_scale                  = number
    cloudsql                   = string
    template_annotations       = map(string)
    autogenerate_revision_name = optional(bool, true)
  }))
}
# variable "cloudrunsql_config" {

# }

# variable "sql_config" {

# }


# variable "image_name" {

# }

# variable "secretmanger_config" {

# }

# # create cloudrun
# # create cloudsql
# # 
