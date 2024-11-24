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
  name     = "infra"
  location = "us-central1"
  project  = local.project.project_id
  disabled = false
  source_to_build {
    repo_type  = "GITHUB"
    ref        = "refs/heads/main"
    repository = "projects/proj-dev-demo000-gbjy/locations/us-central1/connections/test/repositories/gcp-infra-iac"

  }

  substitutions = {
    _TFACTION = "apply"
  }

  git_file_source {
    path       = "workspace/devops/infra_cloudbuild.yaml"
    repository = "projects/proj-dev-demo000-gbjy/locations/us-central1/connections/test/repositories/gcp-infra-iac"
    revision   = "refs/heads/main"
    repo_type  = "GITHUB"
  }


  service_account = "projects/${local.project.project_id}/serviceAccounts/sera-dev-demo-core000@proj-dev-demo000-gbjy.iam.gserviceaccount.com"
}

# import {
#   id = "projects/proj-dev-demo000-gbjy/locations/us-central1/triggers/1affa7d9-c88d-4011-b1f5-d311f7a8747d"
#   to = google_cloudbuild_trigger.trigger
# }
