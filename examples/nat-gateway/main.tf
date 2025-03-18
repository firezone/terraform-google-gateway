provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "compute-api" {
  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_service_account" "firezone" {
  account_id  = "firezone-gateway"
  description = "Service account for gateway Firezone Gateway instances."
}

module "gateways" {
  source = "firezone/gateway/google"

  project_id = var.project_id

  compute_network    = google_compute_network.firezone.id
  compute_subnetwork = google_compute_subnetwork.firezone.id

  compute_instance_replicas = var.replicas
  compute_instance_type     = var.machine_type
  compute_region            = var.region

  # Since we are behind a NAT gateway, we don't need public IP addresses
  # to be automatically provisioned for the instances
  compute_provision_public_ipv6_address = false
  compute_provision_public_ipv4_address = false

  observability_log_level = var.log_level

  vsn = "latest"

  token      = var.token
  depends_on = [google_project_service.compute-api]
}
