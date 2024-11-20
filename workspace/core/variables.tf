variable "organization" {
  type = object({
    domain = string
    id     = optional(string)
  })

  default = {
    domain = "wissen.com"
  }
}

variable "metadata" {
  type = object({
    workload    = string
    sequence    = string
    environment = string
    region      = string
  })
}
