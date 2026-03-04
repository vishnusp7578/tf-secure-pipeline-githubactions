terraform {
  backend "gcs" {
    bucket  = "vsp-tf-state-2"
    prefix  = "prod"   
  }
}
