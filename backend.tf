terraform {
  backend "gcs" {
    bucket  = "vsp-tf-state-1"
    prefix  = "prod"  
  }
}
