metadata = {
  workload    = "demo",
  environment = "dev",
  sequence    = "000",
  region      = "us-central1"
  identifier  = "services"
}

import_state = [
  {
    workload    = "demo",
    environment = "dev",
    sequence    = "000",
    region      = "us-central1"
    identifier  = "core" ## name of directory to import state
  }
]

cloudsql = [
  {
    purpose          = "node_js_db"
    database_version = "MYSQL_8_0"
    tier             = "db-f1-micro"
    backup_configuration = {
      binary_log_enabled = true
      location           = "us"
    }
    ipv4_enabled        = false
    ssl_mode            = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    deletion_protection = false
    sql_user_name       = "admin"
    sql_user_pass       = "securepassword"
  }
]

cloud_run_services = [
  {
    name                 = "nodejs_demo_app"
    image                = "gcr.io/google-samples/hello-app:2.0"
    container_port       = 3000
    max_scale            = 10
    cloudsql             = "node_js_db"
    env_vars             = {}
    template_annotations = {}
  },
]


app_build_config = {
  build_name = "app-build"
  repo_name  = "gcp-cloudrun-nodejs-mysql-app-deployment"
  ref        = "refs/heads/main"
  repo_url   = "https://github.com/UmeshBuraWissen/gcp-cloudrun-nodejs-mysql-app-deployment.git"
  filename   = "gcp-infra-iac/workspace/services/app_cloudbuild.yaml"
}