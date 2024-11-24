metadata = {
  workload    = "demo",
  environment = "dev",
  sequence    = "000",
  region      = "us-central1"
  identifier  = "devops"
}

github_application_id = "57141306"
github_pat            = "xxx"

iac_build_config = {
  build_name = "iac-build"
  repo_name  = "gcp-infra-iac"
  ref        = "refs/heads/main"
  repo_url   = "https://github.com/UmeshBuraWissen/gcp-infra-iac.git"
  file_path  = "workspace/devops/infra_cloudbuild.yaml"
}
