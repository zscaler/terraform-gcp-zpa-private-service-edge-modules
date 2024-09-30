variable "name_prefix" {
  type        = string
  description = "The name prefix for all your resources"
  default     = "zspse"
  validation {
    condition     = length(var.name_prefix) <= 12
    error_message = "Variable name_prefix must be 12 or less characters."
  }
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+$", var.name_prefix))
    error_message = "Variable name_prefix using invalid characters."
  }
}

variable "credentials" {
  type        = string
  description = "Path to the service account json file for terraform to authenticate to Google Cloud"
}

variable "project" {
  type        = string
  description = "Google Cloud project name"
}

variable "region" {
  type        = string
  description = "Google Cloud region"
}

variable "bastion_ssh_allow_ip" {
  type        = list(string)
  description = "CIDR blocks of trusted networks for bastion host ssh access from Internet"
  default     = ["0.0.0.0/0"]
}

variable "allowed_ports" {
  description = "A list of ports to permit inbound to Service Edge Service VPC. Default empty list means to allow all."
  default     = []
  type        = list(string)
}

variable "subnet_bastion" {
  type        = string
  description = "A subnet IP CIDR for the greenfield/test bastion host in the Management VPC"
  default     = "10.0.0.0/24"
}

variable "subnet_pse" {
  type        = string
  description = "A subnet IP CIDR for the Service Edge VPC"
  default     = "10.0.1.0/24"
}

variable "psevm_instance_type" {
  type        = string
  description = "Service Edge Instance Type"
  default     = "n2-standard-4"
  validation {
    condition = (
      var.psevm_instance_type == "n2-standard-4" ||
      var.psevm_instance_type == "n2-highcpu-4" ||
      var.psevm_instance_type == "n1-standard-4" ||
      var.psevm_instance_type == "n1-highcpu-4" ||
      var.psevm_instance_type == "n2-standard-8" ||
      var.psevm_instance_type == "n2-highcpu-8" ||
      var.psevm_instance_type == "n1-standard-8" ||
      var.psevm_instance_type == "n1-highcpu-8"
    )
    error_message = "Input psevm_instance_type must be set to an approved vm instance type."
  }
}

variable "tls_key_algorithm" {
  type        = string
  description = "algorithm for tls_private_key resource"
  default     = "RSA"
}

variable "pse_count" {
  type        = number
  description = "Default number of Service Edge appliances to create per Instance Group/Availability Zone"
  default     = 1
}

variable "az_count" {
  type        = number
  description = "Default number zonal instance groups to create based on availability zone"
  default     = 1
  validation {
    condition = (
      (var.az_count >= 1 && var.az_count <= 3)
    )
    error_message = "Input az_count must be set to a single value between 1 and 3. Note* some regions have greater than 3 AZs. Please modify az_count validation in variables.tf if you are utilizing more than 3 AZs in a region that supports it."
  }
}

variable "zones" {
  type        = list(string)
  description = "(Optional) Availability zone names. Only required if automatic zones selection based on az_count is undesirable"
  default     = []
}

variable "image_name" {
  type        = string
  description = "Custom image name to be used for deploying Service Edge appliances. Ideally all VMs should be on the same Image as templates always pull the latest from Google Marketplace. This variable is provided if a customer desires to override/retain an old image for existing deployments rather than upgrading and forcing a replacement. It is also inputted as a list to facilitate if a customer desired to manually upgrade select ACs deployed based on the ac_count index"
  default     = ""
}

variable "use_zscaler_image" {
  default     = true
  type        = bool
  description = "By default, Service Edge will deploy via the Zscaler Latest Image. Setting this to false will deploy the latest Red Hat Enterprise Linux 9 Image instead"
}

# ZPA Provider specific variables for Service Edge Group and Provisioning Key creation
variable "byo_provisioning_key" {
  type        = bool
  description = "Bring your own Service Edge Provisioning Key. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo_provisioning_key_name"
  default     = false
}

variable "byo_provisioning_key_name" {
  type        = string
  description = "Existing Service Edge Provisioning Key name"
  default     = "provisioning-key-tf"
}

variable "enrollment_cert" {
  type        = string
  description = "Get name of ZPA enrollment cert to be used for Service Edge provisioning"
  default     = "Service Edge"

  validation {
    condition = (
      var.enrollment_cert == "Service Edge"
    )
    error_message = "Input enrollment_cert must be set to an approved value."
  }
}

variable "pse_group_description" {
  type        = string
  description = "Optional: Description of the Service Edge Group"
  default     = ""
}

variable "pse_group_enabled" {
  type        = bool
  description = "Whether this Service Edge Group is enabled or not"
  default     = true
}

variable "pse_group_country_code" {
  type        = string
  description = "Optional: Country code of this Service Edge Group. example 'US'"
  default     = "US"
}

variable "pse_group_latitude" {
  type        = string
  description = "Latitude of the Service Edge Group. Integer or decimal. With values in the range of -90 to 90"
  default     = "37.33874"
}

variable "pse_group_longitude" {
  type        = string
  description = "Longitude of the Service Edge Group. Integer or decimal. With values in the range of -90 to 90"
  default     = "-121.8852525"
}

variable "pse_group_location" {
  type        = string
  description = "location of the Service Edge Group in City, State, Country format. example: 'San Jose, CA, USA'"
  default     = "San Jose, CA, USA"
}

variable "pse_group_upgrade_day" {
  type        = string
  description = "Optional: Service Edges in this group will attempt to update to a newer version of the software during this specified day. Default value: SUNDAY. List of valid days (i.e., SUNDAY, MONDAY, etc)"
  default     = "SUNDAY"
}

variable "pse_group_upgrade_time_in_secs" {
  type        = string
  description = "Optional: Service Edges in this group will attempt to update to a newer version of the software during this specified time. Default value: 66600. Integer in seconds (i.e., 66600). The integer should be greater than or equal to 0 and less than 86400, in 15 minute intervals"
  default     = "66600"
}

variable "pse_group_override_version_profile" {
  type        = bool
  description = "Optional: Whether the default version profile of the Service Edge Group is applied or overridden. Default: false"
  default     = true
}

variable "pse_group_version_profile_id" {
  type        = string
  description = "Optional: ID of the version profile. To learn more, see Version Profile Use Cases. https://help.zscaler.com/zpa/configuring-version-profile"
  default     = "2"

  validation {
    condition = (
      var.pse_group_version_profile_id == "0" || #Default = 0
      var.pse_group_version_profile_id == "1" || #Previous Default = 1
      var.pse_group_version_profile_id == "2"    #New Release = 2
    )
    error_message = "Input pse_group_version_profile_id must be set to an approved value."
  }
}

variable "pse_is_public" {
  type        = bool
  description = "(Optional) Enable or disable public access for the Service Edge Group. Default value is false"
  default     = false
}

variable "zpa_trusted_network_name" {
  type        = string
  description = "To query trusted network that are associated with a specific Zscaler cloud, it is required to append the cloud name to the name of the trusted network. For more details refer to docs: https://registry.terraform.io/providers/zscaler/zpa/latest/docs/data-sources/zpa_trusted_network"
  default     = "" # a valid example name + cloud >> "Corporate-Network (zscalertwo.net)"
}

variable "provisioning_key_enabled" {
  type        = bool
  description = "Whether the provisioning key is enabled or not. Default: true"
  default     = true
}

variable "provisioning_key_association_type" {
  type        = string
  description = "Specifies the provisioning key type for Service Edges or ZPA Private Service Edges. The supported values are SERVICE_EDGE_GRP and SERVICE_EDGE_GRP"
  default     = "SERVICE_EDGE_GRP"

  validation {
    condition = (
      var.provisioning_key_association_type == "SERVICE_EDGE_GRP"
    )
    error_message = "Input provisioning_key_association_type must be set to an approved value."
  }
}

variable "provisioning_key_max_usage" {
  type        = number
  description = "The maximum number of instances where this provisioning key can be used for enrolling an Service Edge or Service Edge"
  default     = 10
}
