# 1. API Enablement (Stage 1)
resource "google_project_service" "apis" {
  for_each = toset([
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "iamcredentials.googleapis.com",
    "compute.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}


module "gh_oidc" {
  source            = "./modules/WIF"
  pool_id           = "ci-cd"
  pool_display_name = "GitHub Actions Identity Pool"
  github_repo       = "var.github_repo"
  sa_id             = "vpc-provisioner-sa"
  depends_on        = [google_project_service.apis]
} 

# ASSIGN PERMISSIONS (PoLP)
# 1. Network Admin for VPC/Subnet creation
resource "google_project_iam_member" "iam_roles" {
  for_each = toset([
    "roles/compute.networkAdmin",
    "roles/storage.objectAdmin",
    "roles/serviceusage.serviceUsageAdmin"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${module.gh_oidc.sa_email}"
}


#VPC 1
module "vpc1" {
  source = "./modules/vpc"

  name   = "vpc-1"
  region = var.region

  subnets = {
    subnet-a = "10.0.1.0/24"
    subnet-b = "10.0.2.0/24"
  }
} 
