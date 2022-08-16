variable "name" {}


variable "access_key" {
}

variable "secret_key" {
}

variable "region" {
  default = "us-east-2"
}

variable "machine_public_key" {
  default = ""
}

variable "image" {
  # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type - ami-002068ed284fb165b
  default = "ami-002068ed284fb165b"
}

variable "machine_type" {
  default = "t3.xlarge"
}

variable "iam_owner" {
  default = "default"
}

variable "environment" {
  default = "production"
}

