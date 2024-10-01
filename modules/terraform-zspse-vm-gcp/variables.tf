variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the Service Edge module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the Service Edge module resources"
  default     = null
}

variable "user_data" {
  type        = string
  description = "Cloud Init data"
}

variable "project" {
  type        = string
  description = "Google Cloud project name"
}

variable "region" {
  type        = string
  description = "Google Cloud region"
}

variable "zones" {
  type        = list(string)
  description = "Availability zone names"
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

variable "ssh_key" {
  type        = string
  description = "A public key uploaded to the Service Edge instances"
}

variable "pse_count" {
  type        = number
  description = "Default number of Service Edge appliances to create"
  default     = 1
}

variable "psevm_vpc_subnetwork" {
  type        = string
  description = "VPC subnetwork for Service Edge VM MGMT"
}

variable "image_name" {
  type        = string
  description = "Custom image name to be used for deploying Service Edge appliances. Ideally all VMs should be on the same Image as templates always pull the latest from Google Marketplace. This variable is provided if a customer desires to override/retain an old ami for existing deployments rather than upgrading and forcing a replacement. It is also inputted as a list to facilitate if a customer desired to manually upgrade select PSEs deployed based on the pse_count index"
  default     = ""
}

variable "update_policy_type" {
  type        = string
  description = "The type of update process. You can specify either PROACTIVE so that the instance group manager proactively executes actions in order to bring instances to their target versions or OPPORTUNISTIC so that no action is proactively executed but the update will be performed as part of other actions (for example, resizes or recreateInstances calls)"
  default     = "OPPORTUNISTIC"
  validation {
    condition = (
      var.update_policy_type == "PROACTIVE" ||
      var.update_policy_type == "OPPORTUNISTIC"
    )
    error_message = "Input update_policy_type must be set to an approved value."
  }
}

variable "update_policy_replacement_method" {
  type        = string
  description = "The instance replacement method for managed instance groups. Valid values are: RECREATE or SUBSTITUTE. If SUBSTITUTE (default), the group replaces VM instances with new instances that have randomly generated names. If RECREATE, instance names are preserved. You must also set max_unavailable_fixed or max_unavailable_percent to be greater than 0"
  default     = "SUBSTITUTE"
  validation {
    condition = (
      var.update_policy_replacement_method == "RECREATE" ||
      var.update_policy_replacement_method == "SUBSTITUTE"
    )
    error_message = "Input update_policy_replacement_method must be set to an approved value."
  }
}

variable "update_policy_max_surge_fixed" {
  type        = number
  description = "The maximum number of instances that can be created above the specified targetSize during the update process. Conflicts with max_surge_percent. If neither is set, defaults to 1"
  default     = 1
}

variable "update_max_unavailable_fixed" {
  type        = number
  description = "The maximum number of instances that can be unavailable during the update process. Conflicts with max_unavailable_percent. If neither is set, defaults to 1"
  default     = 1
}

variable "disk_size" {
  type        = string
  description = "The size of the image in gigabytes. If not specified, it will inherit the size of its base image"
  default     = "64"
}
