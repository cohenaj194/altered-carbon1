terraform {
  backend "s3" {
    bucket  = "terraform-state-store-ves"
    key     = "foobar/terraform.tfstate"
    region  = "us-west-1"
    encrypt = true
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

locals {
  common_tags = {
    "iam_owner" = var.iam_owner
    "environment" = var.environment
    "Name" = var.name
  }
}

# machine_admin, core user
resource "aws_key_pair" "key" {
  key_name   = "${var.name}-key"
  public_key = var.machine_public_key
}

resource "aws_instance" "vm-web" {
  ami           = var.image
  instance_type = var.machine_type
  key_name = aws_key_pair.key.key_name
  tags = local.common_tags
}

resource "aws_eip" "compute_public_ip" {
  vpc = true
  instance = aws_instance.vm-web.id
  tags = local.common_tags
}

output "public_addresses" {
  value = aws_eip.compute_public_ip.public_ip
}

output "machines" {
  value = aws_instance.vm-web.id
}