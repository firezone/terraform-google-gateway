output "service_account" {
  value = google_service_account.application
}

output "target_tags" {
  value = local.network_tags
}

# Kept for backwards compatibility: the first (and in legacy multi-owner mode,
# only) instance template / instance group.
output "instance_template" {
  value = google_compute_instance_template.application[0]
}

output "instance_group" {
  value = google_compute_region_instance_group_manager.application[0]
}

output "instance_templates" {
  value = google_compute_instance_template.application
}

output "instance_groups" {
  value = google_compute_region_instance_group_manager.application
}
