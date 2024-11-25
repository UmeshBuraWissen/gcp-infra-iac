metadata = {
  workload    = "demo",
  environment = "dev",
  sequence    = "000",
  region      = "us-central1"
  identifier  = "core" ## name of current directory
}

import_state = []

github_application_id = "57141306"

iac_build_config = {
  build_name = "iac-build"
  repo_name  = "gcp-infra-iac"
  ref        = "refs/heads/main"
  repo_url   = "https://github.com/UmeshBuraWissen/gcp-infra-iac.git"
  filename   = "workspace/core/infra_cloudbuild.yaml"
}
