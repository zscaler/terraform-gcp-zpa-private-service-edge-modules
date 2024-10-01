## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment

## Variables are populated automically if terraform is ran via ZSEC bash script.
## Modifying the variables in this file will override any inputs from ZSEC.


#####################################################################################################################
##### Optional: ZPA Provider Resources. Skip to step 3. if you already have an  #####
##### Service Edge Group + Provisioning Key.                                   #####
#####################################################################################################################

## 1. ZPA Service Edge Provisioning Key variables. Uncomment and replace default values as desired for your deployment.
##    For any questions populating the below values, please reference:
##    https://registry.terraform.io/providers/zscaler/zpa/latest/docs/resources/zpa_provisioning_key

#enrollment_cert                                = "Service Edge"
#provisioning_key_name                          = "new_key_name"
#provisioning_key_enabled                       = true
#provisioning_key_max_usage                     = 10

## 2. ZPA Service Edge Group variables. Uncomment and replace default values as desired for your deployment.
##    For any questions populating the below values, please reference:
##    https://registry.terraform.io/providers/zscaler/zpa/latest/docs/resources/zpa_service_edge_group

#pse_group_name                       = "new_group_name"
#pse_group_description                = "group_description"
#pse_group_enabled                    = true
#pse_group_country_code               = "US"
#pse_group_latitude                   = "37.3382082"
#pse_group_longitude                  = "-121.8863286"
#pse_group_location                   = "San Jose, CA, USA"
#pse_group_upgrade_day                = "SUNDAY"
#pse_group_upgrade_time_in_secs       = "66600"
#pse_group_override_version_profile   = true
#pse_group_version_profile_id         = "2"


#####################################################################################################################
##### Optional: ZPA Provider Resources. Skip to step 5. if you added values for steps 1. and 2. #####
##### meaning you do NOT have a provisioning key already.                                       #####
#####################################################################################################################

## 3. By default, this script will create a new Service Edge Group Provisioning Key.
##     Uncomment if you want to use an existing provisioning key (true or false. Default: false)

#byo_provisioning_key                           = true

## 4. Provide your existing provisioning key name. Only uncomment and modify if yo uset byo_provisioning_key to true

#byo_provisioning_key_name                      = "example-key-name"


#####################################################################################################################
##### Terraform/Cloud Environment variables  #####
#####################################################################################################################
## 5. GCP region where Service Edge resources will be deployed. This environment variable is automatically populated if running ZSEC script
##    and thus will override any value set here. Only uncomment and set this value if you are deploying terraform standalone.

#region                                     = "us-central1"

## 6. Path relative to terraform root directory where the service account json file exists for terraform to authenticate to Google Cloud

#credentials                                = "/tmp/pse-tf-service-account.json"

## 7. GCP Project ID to deploy/reference resources created

#project                                    = "pse-host-project"


#####################################################################################################################
##### Custom variables. Only change if required for your environment  #####
#####################################################################################################################
## 8. The name string for all Service Edge resources created by Terraform for Tag/Name attributes. (Default: zspse)
##    Due to GCP character constraints, there are validations where this value must be 12 or less characters and only
##    lower case.

# name_prefix                                = "zspse"

## 9. Service Edge GCP Compute Instance size selection. Uncomment psevm_instance_type line with desired vm size to change.
##    (Default: n2-standard-4)

#psevm_instance_type                         = "n2-standard-4"
#psevm_instance_type                         = "n2-highcpu-4"
#psevm_instance_type                         = "n2-standard-8"
#psevm_instance_type                         = "n2-highcpu-8"
#psevm_instance_type                         = "n1-standard-4"
#psevm_instance_type                         = "n1-highcpu-4"
#psevm_instance_type                         = "n1-standard-8"
#psevm_instance_type                         = "n1-highcpu-8"

## 10. Network Configuration:
##    Subnet space. (Minimum /28 required. Uncomment and modify if byo_vpc is set to true but byo_subnets is left false meaning you want terraform to create 
##    NEW subnets in those existing VPCs.

## Note: These Greenfield templates that include a test workload and bastion host will create a total of two VPC Networks in the same Project ID. Putting
##       Host/Services and Applications in the same Project is generally not a GCP recommended best practice. For simplicity, we will create a "Management"
##       VPC consisting of the public bastion VM (subnet_bastion) and the Service Edge Mgmt NIC (subnet_pse).

#subnet_bastion                             = "10.0.0.0/24"
#subnet_pse                                 = "10.0.1.0/24"

## 11. Availabilty Zone resiliency configuration:

## Option A. By default, Terraform will perform a lookup on the region being deployed for what/how many availability zones are currently available for use.
##           Based on this output, we will take the first X number of available zones per az_count and create Compute Instance Groups in in each. Available 
##           input range 1-3 (Default: 1) 

## Example: Region is us-central1 with az_count set to 2. Terraform will create 1 Instance Group in us-central1-a and 1x Instance Group in us-central1-b
##          (or whatever first two zones report back as available)

az_count = 2


## Option B. If you require Instance Groups to be set explicitly in certain availability zones, you can override the region lookup and set the zones.

## Note: By setting zone names here, Terraform will ignore any value set for variable az_count. We also cannot verify the availability correct naming syntax
##       of the names set.

zones = ["us-central1-a", "us-central1-b"]

## 12. The number of Service Edge appliances to provision per Instance Group/Availability Zone.
##    (Default: varies per deployment type template)
##    E.g. pse_count set to 2 and var.az_count or var.zones set to 2 will create 2x Zonal Instance Groups with 2x target CCs in each Instance Group

pse_count = 2

## 13. Custom image name to used for deploying Service Edge appliances. By default, Terraform will lookup the latest Red Hat Enterprise Linux 9 image version from the Google Marketplace.
##     This variable is provided if a customer desires to override/retain a specific image name/Instance Template version

## Note: It is NOT RECOMMENDED to statically set Service Edge image versions. Zscaler recommends always running/deploying the latest version template

use_zscaler_image = true
