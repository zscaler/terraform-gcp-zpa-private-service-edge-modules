# Zscaler Service Edge / GCP Compute Instance (Service Edge) Module

This module creates all resource dependencies required to configure and deploy Service Edge appliances resliently in Google Cloud including: 1x GCP Compute Template and 1x Instance Groups per availability zone specified. Each Instance Group has a target_size input per variable "ac_count" that specifies how many Service Edges should be deployed in EACH Instance Group.
<br>
<br>
## Considerations:
Zscaler Service Edge runs on any supported ".rpm" based Linux Distro. Since there is currently no Zscaler provided Service Edge image in the GCP marketplace, we default to a supported image: projects/rhel-cloud/global/images/rhel-9-v20240709
<br>
<br>
Zscaler recommends deploying Service Edges via consistent/reusable templates with Compute Instances managed by Zonal Instance Groups. Zscaler does not currently support utilizing GCP specific features of Managed Instance Groups like Instance based Autohealing or Autoscaling with this deployment module.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.4.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.4.0 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_instance_group_manager.pse_instance_group_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager) | resource |
| [google_compute_instance_template.pse_instance_template](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [time_sleep.wait_60_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [google_compute_instance.pse_vm_instances](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance) | data source |
| [google_compute_instance_group.pse_instance_groups](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | The size of the image in gigabytes. If not specified, it will inherit the size of its base image | `string` | `"64"` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Custom image name to be used for deploying Service Edge appliances. Ideally all VMs should be on the same Image as templates always pull the latest from Google Marketplace. This variable is provided if a customer desires to override/retain an old ami for existing deployments rather than upgrading and forcing a replacement. It is also inputted as a list to facilitate if a customer desired to manually upgrade select ACs deployed based on the ac\_count index | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the Service Edge module resources | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud project name | `string` | n/a | yes |
| <a name="input_pse_count"></a> [pse\_count](#input\_pse\_count) | Default number of Service Edge appliances to create | `number` | `1` | no |
| <a name="input_psevm_instance_type"></a> [psevm\_instance\_type](#input\_psevm\_instance\_type) | Service Edge Instance Type | `string` | `"n2-standard-4"` | no |
| <a name="input_psevm_vpc_subnetwork"></a> [psevm\_vpc\_subnetwork](#input\_psevm\_vpc\_subnetwork) | VPC subnetwork for Service Edge VM MGMT | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the Service Edge module resources | `string` | `null` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | A public key uploaded to the Service Edge instances | `string` | n/a | yes |
| <a name="input_update_max_unavailable_fixed"></a> [update\_max\_unavailable\_fixed](#input\_update\_max\_unavailable\_fixed) | The maximum number of instances that can be unavailable during the update process. Conflicts with max\_unavailable\_percent. If neither is set, defaults to 1 | `number` | `1` | no |
| <a name="input_update_policy_max_surge_fixed"></a> [update\_policy\_max\_surge\_fixed](#input\_update\_policy\_max\_surge\_fixed) | The maximum number of instances that can be created above the specified targetSize during the update process. Conflicts with max\_surge\_percent. If neither is set, defaults to 1 | `number` | `1` | no |
| <a name="input_update_policy_replacement_method"></a> [update\_policy\_replacement\_method](#input\_update\_policy\_replacement\_method) | The instance replacement method for managed instance groups. Valid values are: RECREATE or SUBSTITUTE. If SUBSTITUTE (default), the group replaces VM instances with new instances that have randomly generated names. If RECREATE, instance names are preserved. You must also set max\_unavailable\_fixed or max\_unavailable\_percent to be greater than 0 | `string` | `"SUBSTITUTE"` | no |
| <a name="input_update_policy_type"></a> [update\_policy\_type](#input\_update\_policy\_type) | The type of update process. You can specify either PROACTIVE so that the instance group manager proactively executes actions in order to bring instances to their target versions or OPPORTUNISTIC so that no action is proactively executed but the update will be performed as part of other actions (for example, resizes or recreateInstances calls) | `string` | `"OPPORTUNISTIC"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Cloud Init data | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | Availability zone names | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ac_instance"></a> [ac\_instance](#output\_ac\_instance) | Service Edge VM name |
| <a name="output_ac_private_ip"></a> [ac\_private\_ip](#output\_ac\_private\_ip) | Service Edge VM internal forwarding IP |
| <a name="output_instance_group_ids"></a> [instance\_group\_ids](#output\_instance\_group\_ids) | Name for Instance Groups |
| <a name="output_instance_group_names"></a> [instance\_group\_names](#output\_instance\_group\_names) | Name for Instance Groups |
| <a name="output_instance_group_zones"></a> [instance\_group\_zones](#output\_instance\_group\_zones) | GCP Zone assigmnents for Instance Groups |
| <a name="output_instance_template_project"></a> [instance\_template\_project](#output\_instance\_template\_project) | GCP Project for Compute Instance Template and resource placement |
| <a name="output_instance_template_region"></a> [instance\_template\_region](#output\_instance\_template\_region) | GCP Region for Compute Instance Template and resource placement |
<!-- END_TF_DOCS -->
