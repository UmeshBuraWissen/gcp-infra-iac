variable "project_id" {
  description = "The ID of the project in which to create the instance."
  type        = string
}

variable "name" {
  description = "The name of the SQL instance."
  type        = string
}

variable "region" {
  description = "The region where the SQL instance will be created."
  type        = string
}

variable "database_version" {
  description = "The version of the database."
  type        = string
  default     = "MYSQL_8_0"
}

variable "tier" {
  description = "The machine type to use."
  type        = string
  default     = "db-f1-micro"
}

variable "backup_configuration" {
  type = object({
    binary_log_enabled = bool
    location           = string
  })
  default = null
}

variable "ipv4_enabled" {
  description = "Whether IPv4 is enabled."
  type        = bool
  default     = false
}

variable "ssl_mode" {
  description = "The SSL mode to use."
  type        = string
  default     = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "sql_user_name" {
  description = "The name of the SQL user."
  type        = string
}

variable "sql_user_pass" {
  description = "The password for the SQL user."
  type        = string
  sensitive   = true
}
