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

variable "metadata" {
  type = object({
    workload    = string
    sequence    = string
    environment = string
    region      = string
    identifier  = string
  })
}

variable "import_state" {
  type = list(object({
    workload    = string
    sequence    = string
    environment = string
    region      = string
    identifier  = string
  }))
}

variable "github_application_id" {
  type = string
}

variable "iac_build_config" {
  type = object({
    build_name = string
    repo_name  = string
    repo_url   = string
    ref        = string
    filename   = string
  })
}
