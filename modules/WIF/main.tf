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
  attribute_condition = "attribute.repository.lower() == '${var.github_repo}'"

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

# Allow the Repository to impersonate this Service Account
resource "google_service_account_iam_member" "impersonation" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repo}"
}
