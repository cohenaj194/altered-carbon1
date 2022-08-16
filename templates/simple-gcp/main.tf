terraform {
  backend "s3" {
    bucket  = "terraform-state-store-ves"
    key     = "foobar/terraform.tfstate"
    region  = "us-west-1"
    encrypt = true
  }
}

# GCP vars
variable "gcp_credentials_file_path" {}
variable "gcp_project_name" {}
variable "region" {
  default = "us-west1"
}
variable "zone" {
  default = "us-west1-c"
}
variable "image" {
  default = "centos-7-v20211214"
}
variable "machine_type" {
  default = "n1-standard-4"
}
variable "machine_disk_size" {
  default = "40"
}

variable "name" {}
variable "machine_public_key" {}
variable "environment" {
  default = "production"
}


locals {
  common_tags = [var.name, var.environment]
}

# providers
provider "google" {
 credentials = file(var.gcp_credentials_file_path)
 project     = var.gcp_project_name
 region      = var.region
 zone        = var.zone
}

resource "google_compute_instance" "instances" {
  name = var.name
  machine_type = var.machine_type
  boot_disk {
    initialize_params {
      image = var.image
      size  = var.machine_disk_size
    }
  }
  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
  metadata = {
    ssh-keys = "centos:${var.machine_public_key}"
  }
  service_account {
    scopes = ["cloud-platform"]
  }
  tags = local.common_tags
}

output "public_addresses" {
  value = google_compute_instance.instances.network_interface[0].access_config[0].nat_ip
}
