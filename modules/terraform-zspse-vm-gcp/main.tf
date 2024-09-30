################################################################################
# Create Service Edge Instance Template
################################################################################
resource "google_compute_instance_template" "pse_instance_template" {
  name_prefix = "${var.name_prefix}-template-${var.resource_tag}"
  project     = var.project
  region      = var.region

  machine_type = var.psevm_instance_type

  disk {
    source_image = var.image_name
    auto_delete  = true
    boot         = true
    disk_type    = "pd-balanced"
    disk_size_gb = var.disk_size
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  network_interface {
    subnetwork = var.psevm_vpc_subnetwork
  }

  metadata = {
    ssh-keys                = "admin:${var.ssh_key}"
    enable-guest-attributes = "TRUE"
  }

  metadata_startup_script = var.user_data

  lifecycle {
    create_before_destroy = true
  }
}


################################################################################
# Create Zonal Managed Instance Groups per number of zones defined
# Create X number of Service Edges in each group per pse_count variable
################################################################################
resource "google_compute_instance_group_manager" "pse_instance_group_manager" {
  count   = length(var.zones)
  name    = "${var.name_prefix}-instance-group-${count.index + 1}-${var.resource_tag}"
  project = var.project
  zone    = element(var.zones, count.index)

  base_instance_name = "${var.name_prefix}-group-${count.index + 1}vm-${var.resource_tag}"
  version {
    instance_template = google_compute_instance_template.pse_instance_template.id
  }
  target_size = var.pse_count

  update_policy {
    type                           = var.update_policy_type
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = var.update_policy_max_surge_fixed
    max_unavailable_fixed          = var.update_max_unavailable_fixed
    replacement_method             = var.update_policy_replacement_method
  }

  lifecycle {
    create_before_destroy = true
  }
}


################################################################################
# Wait for Instance Group creation to collect individual compute details
################################################################################
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [google_compute_instance_group_manager.pse_instance_group_manager]
  create_duration = "60s"
}

data "google_compute_instance_group" "pse_instance_groups" {
  count     = length(google_compute_instance_group_manager.pse_instance_group_manager[*].instance_group)
  self_link = element(google_compute_instance_group_manager.pse_instance_group_manager[*].instance_group, count.index)

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

data "google_compute_instance" "pse_vm_instances" {
  count     = var.pse_count * length(var.zones)
  self_link = element(tolist(flatten([for instances in data.google_compute_instance_group.pse_instance_groups[*].instances : instances])), count.index)
}
