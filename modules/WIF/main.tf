# Create the Workload Identity Pool
resource "google_iam_workload_identity_pool" "pool" { 
  workload_identity_pool_id = var.pool_id
  display_name              = var.pool_display_name
}

# Create the Workload Identity Provider for GitHub
resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id 
  workload_identity_pool_provider_id = "github-provider"

  # Banking Security: Only allow your specific repo to connect
 attribute_condition = "attribute.repository == '${var.github_repo}'"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Create the Automation Service Account
resource "google_service_account" "sa" {
  account_id   = var.sa_id
  display_name = "Service Account for ${var.github_repo}"
}


# Consolidate both roles into a single loop to ensure they are applied together
resource "google_service_account_iam_member" "wif_roles" {
  for_each = toset([
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/storage.objectAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/compute.networkAdmin",
    "roles/resourcemanager.projectIamAdmin"
  ])
  service_account_id = google_service_account.sa.name
  role               = each.value
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repo}"
}
