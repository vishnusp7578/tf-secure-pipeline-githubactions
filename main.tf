module "gh_oidc" {
  source            = "./modules/wif"
  pool_id           = "ci-cd"
  pool_display_name = "GitHub Actions Identity Pool"
  github_repo       = ""
  sa_id             = "vpc-provisioner-sa"
} 

# ASSIGN PERMISSIONS (PoLP)
# 1. Network Admin for VPC/Subnet creation
resource "google_project_iam_member" "network_admin" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${module.gh_oidc.sa_email}"
}

# 2. Storage Admin for the Terraform State bucket
resource "google_project_iam_member" "state_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${module.gh_oidc.sa_email}"
}

resource "google_project_iam_member" "service_usage_admin" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${module.gh_oidc.sa_email}"
}

/* #VPC 1
module "vpc1" {
  source = "./modules/vpc"

  name   = "vpc-1"
  region = var.region

  subnets = {
    subnet-a = "10.0.1.0/24"
    subnet-b = "10.0.2.0/24"
  }
} */
