build_config = [
  {
    name = "infra-cloud-build"
    project  =  "proj-dev-demo000-gbjy"
  disabled = false
    path = "infra_cloudbuild.yaml"
    owner = "UmeshBuraWissen"
    github_reponame  = "gcp-infra-iac"
      branch       = "^main$"
      invert_regex = false
      service_account = "sera-dev-demo-core000@proj-dev-demo000-gbjy.iam.gserviceaccount.com"
    _TFACTION = "apply"
  }
]