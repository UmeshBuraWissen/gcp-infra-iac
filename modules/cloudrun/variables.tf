variable "name" {
  description = "The name of the Cloud Run service"
  type        = string
}

variable "location" {
  description = "The location of the Cloud Run service"
  type        = string
}

variable "project_id" {
  description = "The project ID where the Cloud Run service will be deployed"
  type        = string
}

variable "service_account_name" {
  description = "The service account name to be used by the Cloud Run service"
  type        = string
}

variable "image" {
  description = "The container image to be used by the Cloud Run service"
  type        = string
}

variable "env_vars" {
  description = "A map of environment variables to be set in the container"
  type        = map(string)
  default     = {}
}

variable "container_port" {
  description = "The port on which the container listens"
  type        = number
}

variable "template_annotations" {
  description = "Annotations to be added to the Cloud Run service template"
  type        = map(string)
  default     = {}
}

variable "autogenerate_revision_name" {
  description = "Whether to autogenerate the revision name"
  type        = bool
  default     = true
}

variable "vpc_access_connector" {
  type    = string
  default = null
}
