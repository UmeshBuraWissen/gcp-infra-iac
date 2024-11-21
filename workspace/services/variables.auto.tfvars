metadata = {
  workload    = "demo",
  environment = "dev",
  sequence    = "000",
  region      = "us-central1"
  identifier  = "services"
}


cloudrunsql_config = [
  {
    name     = "wissen-nodejs-app-gcp-cloudrun-mysql-1"
    location = "us-central1"
    #project_id                 = "gcp-cloudrun-nodejs-mysql-app"
    image                      = "nodejsapp:latest"
    maxScale                   = "10"
    sql_name                   = "wissen-nodejs-app-gcp-mysql"
    client-name                = "terraform"
    autogenerate_revision_name = true
    timeout_seconds            = 6000
    service_account_name       = "nodejsdemo@gcp-cloudrun-nodejs-mysql-app.iam.gserviceaccount.com"
    envs = {
      "port"             = "3000"
      "projectid"        = "348355234668"
      "dbconnectionname" = "proj-dev-demo000-gbjy:us-central1:wissen-nodejs-app-gcp-mysql"
    }
  }
]


sql_config = [
  {
    location = "us-central1"
    #project_id          = "gcp-cloudrun-nodejs-mysql-app"
    sql_name            = "wissen-nodejs-app-gcp-mysql"
    database_version    = "MYSQL_8_0"
    deletion_protection = false
    sql_user_name       = "nodejsuser"
    sql_user_pass       = "Wissen12345"
    #private-network-name                    = "private-network"
    private-network-name    = "wissen-nodejs-app-gcp-vpc"
    auto_create_subnetworks = false
    #private-ip-address-name          = "private-ip-address"
    private-ip-address-name = "wissen-nodejs-app-gcp-private-ip-address"
    purpose                 = "VPC_PEERING"
    address_type            = "INTERNAL"
    prefix_length           = 16
    service                 = "servicenetworking.googleapis.com"
    #firewall_name    = "deny-all-ingress"
    firewall_name        = "wissen-nodejs-app-gcp-deny-all-ingress"
    protocol             = "all"
    direction            = "INGRESS"
    priority             = 1000
    source_ranges        = ["0.0.0.0/0"]
    tier                 = "db-f1-micro"
    enabled              = true
    binary_log_enabled   = true
    ipv4_enabled         = false
    ssl_mode             = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    require_ssl          = false
    import_custom_routes = true
    export_custom_routes = true
  }
]


image_name = "nodejsapp:latest"

secretmanger_config = [{
  secret_id   = "DB_USERNAME"
  secret_data = "nodejsuser"
  },
  {
    secret_id   = "DB_PASSWORD"
    secret_data = "Wissen12345"
}]
