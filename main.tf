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
  github_repo       = var.github_repo
  sa_id             = "vpc-provisioner-sa"
  depends_on        = [google_project_service.apis]
  project_id        = var.project_id
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

module "vm_a" {
  source  = "./modules/vm"
  name    = "vm-a"
  zone    = var.zone_a
  subnet  = module.vpc1.subnets["subnet-a"]
  tags    = ["ssh","web"]
  external_ip = true
}

module "vm_b" {
  source  = "./modules/vm"
  name    = "vm-b"
  zone    = var.zone_b
  subnet  = module.vpc1.subnets["subnet-b"]
  tags    = ["private"]
  external_ip = false
}

 module "firewall" {
  source  = "./modules/firewall"
  network = module.vpc1.network
  depends_on = [module.gh_oidc.iam_roles_created]

}
