variable "name_prefix" {
  type    = string
  default = "auto"
}

variable "region" {}

variable "network" {
  type = string
}

variable "subnet_name" {
  type        = string
  description = "The subnet to attach NAT to"
}
