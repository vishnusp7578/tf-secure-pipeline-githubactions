resource "google_compute_router" "vpc1_router" {
  name    = "${var.name_prefix}-router-${var.region}"
  network = var.network
  region  = var.region
}

resource "google_compute_router_nat" "vpc1_nat" {
  name                       = "${var.name_prefix}-router-${var.region}"
  router                     = google_compute_router.vpc1_router.name
  region                     = var.region
  nat_ip_allocate_option      = "AUTO_ONLY" # Automatically allocate external IPs
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                     = module.vpc1.subnets["subnet-b"]
    source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
  }
}
