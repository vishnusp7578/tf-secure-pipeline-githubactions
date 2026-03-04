variable "network" {}

resource "google_compute_firewall" "allow_internal_icmp" {
  name    = "allow-internal-icmp"
  network = module.vpc1.network

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/16"] 
}



resource "google_compute_firewall" "ssh_iap" {
  name    = "allow-ssh-iap"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Required source range for IAP TCP forwarding
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["ssh"]
}
