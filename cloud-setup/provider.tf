variable "project_name" {}
variable "region" {}

provider "google" {
    credentials = "${file("../.config/${var.project_name}-tf-service-account-key.json")}"
    project     = var.project_name
    region      = var.region
}