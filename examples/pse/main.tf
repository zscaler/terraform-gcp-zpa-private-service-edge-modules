################################################################################
# Generate a unique random string for resource name assignment and key pair
################################################################################
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}


################################################################################
# The following lines generates a new SSH key pair and stores the PEM file
# locally. The public key output is used as the ssh_key passed variable
# to the compute modules for admin_ssh_key public_key authentication.
# This is not recommended for production deployments. Please consider modifying
# to pass your own custom public key file located in a secure location.
################################################################################
resource "tls_private_key" "key" {
  algorithm = var.tls_key_algorithm
}

resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "./${var.name_prefix}-key-${random_string.suffix.result}.pem"
  file_permission = "0600"
}


################################################################################
# 1. Create/reference all network infrastructure resource dependencies for all
#    child modules (vpc, router, nat gateway, subnets)
################################################################################
module "network" {
  source                         = "../../modules/terraform-zspse-network-gcp"
  name_prefix                    = var.name_prefix
  resource_tag                   = random_string.suffix.result
  project                        = var.project
  region                         = var.region
  allowed_ssh_from_internal_cidr = [var.subnet_bastion]
  allowed_ports                  = var.allowed_ports
  subnet_pse                      = var.subnet_pse

  byo_vpc      = var.byo_vpc
  byo_vpc_name = var.byo_vpc_name

  byo_subnets     = var.byo_subnets
  byo_subnet_name = var.byo_subnet_name

  byo_router      = var.byo_router
  byo_router_name = var.byo_router_name

  byo_natgw      = var.byo_natgw
  byo_natgw_name = var.byo_natgw_name
}


################################################################################
# 3. Create ZPA Service Edge Group
################################################################################
module "zpa_service_edge_group" {
  count                              = var.byo_provisioning_key == true ? 0 : 1 # Only use this module if a new provisioning key is needed
  source                             = "../../modules/terraform-zpa-service-edge-group"
  pse_group_name                     = "${var.region}-${module.network.vpc_network_name}"
  pse_group_description              = "${var.pse_group_description}-${var.region}-${module.network.vpc_network_name}"
  pse_group_enabled                  = var.pse_group_enabled
  pse_group_country_code             = var.pse_group_country_code
  pse_group_latitude                 = var.pse_group_latitude
  pse_group_longitude                = var.pse_group_longitude
  pse_group_location                 = var.pse_group_location
  pse_group_upgrade_day              = var.pse_group_upgrade_day
  pse_group_upgrade_time_in_secs     = var.pse_group_upgrade_time_in_secs
  pse_group_override_version_profile = var.pse_group_override_version_profile
  pse_group_version_profile_id       = var.pse_group_version_profile_id
  pse_is_public                      = var.pse_is_public
  zpa_trusted_network_name           = var.zpa_trusted_network_name
}



################################################################################
# 3. Create ZPA Provisioning Key (or reference existing if byo set)
################################################################################
module "zpa_provisioning_key" {
  source                            = "../../modules/terraform-zpa-provisioning-key"
  enrollment_cert                   = var.enrollment_cert
  provisioning_key_name             = "${var.region}-${module.network.vpc_network_name}"
  provisioning_key_enabled          = var.provisioning_key_enabled
  provisioning_key_association_type = var.provisioning_key_association_type
  provisioning_key_max_usage        = var.provisioning_key_max_usage
  pse_group_id                      = try(module.zpa_service_edge_group[0].service_edge_group_id, "")
  byo_provisioning_key              = var.byo_provisioning_key
  byo_provisioning_key_name         = var.byo_provisioning_key_name
}


################################################################################
# A. Create the user_data file with necessary bootstrap variables for
#    PSE registration. Used if variable use_zscaler_ami is set to true.
################################################################################
locals {
  pseuserdata = <<PSEUSERDATA
#!/bin/bash 
#Stop the Service Edge service which was auto-started at boot time 
systemctl stop zpa-service-edge 
#Create a file from the Service Edge provisioning key created in the ZPA Admin Portal 
#Make sure that the provisioning key is between double quotes 
echo "${module.zpa_provisioning_key.provisioning_key}" > /opt/zscaler/var/service-edge/provision_key
#Run a yum update to apply the latest patches 
yum update -y 
#Start the Service Edge service to enroll it in the ZPA cloud 
systemctl start zpa-service-edge 
#Wait for the Service Edge to download latest build 
sleep 60 
#Stop and then start the Service Edge for the latest build 
systemctl stop zpa-service-edge 
systemctl start zpa-service-edge
PSEUSERDATA
}

resource "local_file" "user_data_file" {
  count    = var.use_zscaler_image == true ? 1 : 0
  content  = local.pseuserdata
  filename = "./user_data"
}

################################################################################
# 5. Create specified number PSE VMs per pse_count which will span equally across 
#    designated availability zones per az_count. E.g. pse_count set to 4 and 
#    az_count set to 2 will create 2x PSEs in AZ1 and 2x PSEs in AZ2
################################################################################
# Create the user_data file with necessary bootstrap variables for Service Edge registration
locals {
  rhel9userdata = <<RHEL9USERDATA
#!/usr/bin/bash
# Sleep to allow the system to initialize
sleep 15

# Create the Zscaler repository file
touch /etc/yum.repos.d/zscaler.repo
cat > /etc/yum.repos.d/zscaler.repo <<-EOT
[zscaler]
name=Zscaler Private Access Repository
baseurl=https://yum.private.zscaler.com/yum/el9
enabled=1
gpgcheck=1
gpgkey=https://yum.private.zscaler.com/yum/el9/gpg
EOT

# Sleep to allow the repo file to be registered
sleep 60

# Install unzip
yum install -y unzip

# Download and install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update -i /usr/bin/aws-cli -b /usr/bin

# Verify AWS CLI installation
/usr/bin/aws --version

# Install Service Edge packages
yum install zpa-service-edge -y

# Stop the Service Edge service which was auto-started at boot time
systemctl stop zpa-service-edge

# Create a file from the Service Edge provisioning key created in the ZPA Admin Portal
# Make sure that the provisioning key is between double quotes
echo "${module.zpa_provisioning_key.provisioning_key}" > /opt/zscaler/var/provision_key
chmod 644 /opt/zscaler/var/provision_key

# Run a yum update to apply the latest patches
yum update -y

# Start the Service Edge service to enroll it in the ZPA cloud
systemctl start zpa-service-edge

# Wait for the Service Edge to download the latest build
sleep 60

# Stop and then start the Service Edge for the latest build
systemctl stop zpa-service-edge
systemctl start zpa-service-edge
RHEL9USERDATA
}

# Write the file to local filesystem for storage/reference
resource "local_file" "rhel9_user_data_file" {
  count    = var.use_zscaler_image == true ? 0 : 1
  content  = local.rhel9userdata
  filename = "./user_data"
}

################################################################################
# Locate Latest Service Edge Image on Google Markeplace by Project and Name
################################################################################
data "google_compute_image" "service_edge" {
  count   = var.use_zscaler_image ? 1 : 0
  project = "mpi-zpa-gcp-marketplace"
  name    = "zpa-service-edge-el9-2024-08"
}


################################################################################
# Locate Latest Red Hat Enterprise Linux 9 Image for instance use
################################################################################
data "google_compute_image" "rhel_9_latest" {
  count   = var.image_name != "" ? 0 : 1
  family  = "rhel-9"
  project = "rhel-cloud"
}

locals {
  image_selected = try(data.google_compute_image.service_edge[0].self_link, data.google_compute_image.rhel_9_latest[0].self_link)
}

################################################################################
# Query for active list of available zones for var.region
################################################################################
data "google_compute_zones" "available" {
  status = "UP"
}

locals {
  zones_list = length(var.zones) == 0 ? slice(data.google_compute_zones.available.names, 0, var.az_count) : distinct(var.zones)
}


################################################################################
# Create Service Edge VM instances
################################################################################
module "pse_vm" {
  source              = "../../modules/terraform-zspse-vm-gcp"
  name_prefix         = var.name_prefix
  resource_tag        = random_string.suffix.result
  project             = var.project
  region              = var.region
  zones               = local.zones_list
  psevm_instance_type  = var.psevm_instance_type
  ssh_key             = tls_private_key.key.public_key_openssh
  user_data           = var.use_zscaler_image == true ? local.pseuserdata : local.rhel9userdata
  pse_count            = var.pse_count
  psevm_vpc_subnetwork = module.network.pse_subnet
  image_name          = var.image_name != "" ? var.image_name : local.image_selected
}
