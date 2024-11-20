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
