output "ac_private_ip" {
  description = "Service Edge VM internal forwarding IP"
  value       = data.google_compute_instance.pse_vm_instances[*].network_interface[0].network_ip
}

output "instance_group_zones" {
  description = "GCP Zone assigmnents for Instance Groups"
  value       = google_compute_instance_group_manager.pse_instance_group_manager[*].zone
}

output "instance_group_names" {
  description = "Name for Instance Groups"
  value       = google_compute_instance_group_manager.pse_instance_group_manager[*].name
}

output "instance_group_ids" {
  description = "Name for Instance Groups"
  value       = google_compute_instance_group_manager.pse_instance_group_manager[*].instance_group
}

output "instance_template_region" {
  description = "GCP Region for Compute Instance Template and resource placement"
  value       = google_compute_instance_template.pse_instance_template.region
}

output "instance_template_project" {
  description = "GCP Project for Compute Instance Template and resource placement"
  value       = google_compute_instance_template.pse_instance_template.project
}

output "ac_instance" {
  description = "Service Edge VM name"
  value       = data.google_compute_instance.pse_vm_instances[*].self_link
}
