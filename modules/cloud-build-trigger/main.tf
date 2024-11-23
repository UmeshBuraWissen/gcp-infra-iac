resource "google_cloudbuild_trigger" "trigger" {
  name     = var.name
  location = "us-central1"
  project  = var.project
  disabled = var.disabled
  source_to_build {
    repo_type = "GITHUB"
    ref       = "refs/heads/main"
    uri       = "https://github.com/UmeshBuraWissen/gcp-infra-iac.git"
  }
  github {
    owner = var.owner
    name  = var.github_reponame
    push {
      branch       = var.branch
      invert_regex = var.invert_regex
    }
  }
  substitutions = {
    _TFACTION = var._TFACTION
  }

  # git_file_source {
  #   path      = "devops/infra_cloudbuild.yaml"
  #   uri       = "https://github.com/UmeshBuraWissen/gcp-infra-iac.git"
  #   revision  = "refs/heads/main"
  #   repo_type = "GITHUB"
  # }


  service_account = "projects/${var.project}/serviceAccounts/${var.service_account}"
  filename        = var.path
}
