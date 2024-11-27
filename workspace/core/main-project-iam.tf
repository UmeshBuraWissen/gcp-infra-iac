## Project Owners
resource "google_project_iam_member" "owners" {
  for_each = toset(var.project_owners)

  project = local.project.project_id
  role    = "roles/owner"
  member  = each.value

  depends_on = [data.google_project.current]
}
