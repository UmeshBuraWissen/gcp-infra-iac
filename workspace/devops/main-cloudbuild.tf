# module "cloud-build-trigger" {
#   source          = "../../modules/cloud-build-trigger"
#   for_each        = { for i in var.build_config : i.name => i }
#   name            = each.value["name"]
#   project         = each.value["project"]
#   disabled        = each.value["disabled"]
#   path            = each.value["path"]
#   owner           = each.value["owner"]
#   github_reponame = each.value["github_reponame"]
#   branch          = each.value["branch"]
#   invert_regex    = each.value["invert_regex"]
#   service_account = each.value["service_account"]
#   _TFACTION       = each.value["_TFACTION"]
# }

resource "google_cloudbuild_trigger" "trigger" {
  name     = "infra-cloud-build"
  location = "us-central1"
  project  = local.project.project_id
  disabled = false
  source_to_build {
    repo_type = "GITHUB"
    ref       = "refs/heads/main"
    uri       = "https://github.com/UmeshBuraWissen/gcp-infra-iac.git"
  }
  github {
    owner = "UmeshBuraWissen"
    name  = "gcp-infra-iac"
    push {
      branch       = "^main$"
      invert_regex = false
    }
  }
  substitutions = {
    _TFACTION = "apply"
  }

  # git_file_source {
  #   path      = "devops/infra_cloudbuild.yaml"
  #   uri       = "https://github.com/UmeshBuraWissen/gcp-infra-iac.git"
  #   revision  = "refs/heads/main"
  #   repo_type = "GITHUB"
  # }


  service_account = "projects/${local.project.project_id}/serviceAccounts/sera-dev-demo-core000@proj-dev-demo000-gbjy.iam.gserviceaccount.com"
  filename        = "infra_cloudbuild.yaml"
}
