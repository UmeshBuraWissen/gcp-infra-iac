data "google_artifact_registry_docker_image" "my_image" {
  location      = data.google_artifact_registry_repository.my-repo.location
  repository_id = "areg-dev-usce1-demo-core000" #module.bootstrap.resource_name.google_artifact_registry_repository
  image_name    = var.image_name
  project       = local.project.project_id

}

data "google_artifact_registry_repository" "my-repo" {
  location      = "us"                          #var.location
  repository_id = "areg-dev-usce1-demo-core000" #module.bootstrap.resource_name.google_artifact_registry_repository
  project       = local.project.project_id      #var.project
}


module "cloudRun" {
  source     = "../../modules/cloudrun"
  for_each   = { for i in var.cloudrunsql_config : i.name => i }
  name       = each.value["name"]
  location   = var.metadata.region #each.value["location"]
  project_id = local.project.project_id
  envs       = merge(each.value["envs"], { "dbconnectionname" = module.cloudSql[each.value["sql_name"]].private_ip_address }) ## add ip address of cloudsql private ip
  template = {
    spec = {
      containers = {
        image = data.google_artifact_registry_docker_image.my_image.self_link
      }
    }
  }
  metadata = {
    annotations = {
      maxScale            = each.value["maxScale"]
      connection_name     = module.cloudSql[each.value["sql_name"]].connection_name
      client-name         = each.value["client-name"]
      vpc_access_conector = google_vpc_access_connector.connector.id # "projects/proj-dev-demo000-gbjy/locations/us-central1/connectors/test-serverless-vpc"
    }
  }
  autogenerate_revision_name = each.value["autogenerate_revision_name"]
  timeout_seconds            = each.value["timeout_seconds"]
  service_account_name       = "sera-dev-demo-core000@proj-dev-demo000-gbjy.iam.gserviceaccount.com" #each.value["service_account_name"]
  depends_on                 = [module.cloudSql]

}
