# Zscaler "ac" deployment type

This deployment type is intended for production/brownfield purposes. Full set of resources provisioned listed below, but by default this will effectively create all network infrastructure dependencies for a GCP environment. Creates 1 new "Management" VPC with 1 AC subnet and 1 bastion subnet; 1 Cloud Router + NAT Gateway; 1 Bastion Host assigned a dynamic public IP; generates local key pair .pem file for ssh access to all VMs. All network infrastructure resource have conditional "byo" variables, that can be inputted if they already exist (like VPC, subnet, Cloud Router, and Cloud NAT)<br>

Additionally: Creates 1 Service Edge compute instance template + option to deploy multiple Service Edges across multiple zonal managed instance groups for highly available/resilient workload Zero Trust App Access.


## How to deploy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec up
- enter "greenfield"
- enter "ac"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in ac/terraform.tfvars file and save.

From ac directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec destroy

### Option 2 (manual):
From ac directory execute:
- terraform destroy

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.4.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.0 |
| <a name="requirement_zpa"></a> [zpa](#requirement\_zpa) | ~> 3.33.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.4.0 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | ../../modules/terraform-zspse-network-gcp | n/a |
| <a name="module_pse_vm"></a> [pse\_vm](#module\_pse\_vm) | ../../modules/terraform-zspse-vm-gcp | n/a |
| <a name="module_zpa_provisioning_key"></a> [zpa\_provisioning\_key](#module\_zpa\_provisioning\_key) | ../../modules/terraform-zpa-provisioning-key | n/a |
| <a name="module_zpa_service_edge_group"></a> [zpa\_service\_edge\_group](#module\_zpa\_service\_edge\_group) | ../../modules/terraform-zpa-service-edge-group | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.rhel9_user_data_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.testbed](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.user_data_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [google_compute_image.rhel_9_latest](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_image.service_edge](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ports"></a> [allowed\_ports](#input\_allowed\_ports) | A list of ports to permit inbound to Service Edge Service VPC. Default empty list means to allow all. | `list(string)` | `[]` | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Default number zonal instance groups to create based on availability zone | `number` | `1` | no |
| <a name="input_byo_natgw"></a> [byo\_natgw](#input\_byo\_natgw) | Bring your own GCP NAT Gateway Cloud Connector | `bool` | `false` | no |
| <a name="input_byo_natgw_name"></a> [byo\_natgw\_name](#input\_byo\_natgw\_name) | User provided existing GCP NAT Gateway friendly name | `string` | `null` | no |
| <a name="input_byo_provisioning_key"></a> [byo\_provisioning\_key](#input\_byo\_provisioning\_key) | Bring your own Service Edge Provisioning Key. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo\_provisioning\_key\_name | `bool` | `false` | no |
| <a name="input_byo_provisioning_key_name"></a> [byo\_provisioning\_key\_name](#input\_byo\_provisioning\_key\_name) | Existing Service Edge Provisioning Key name | `string` | `"provisioning-key-tf"` | no |
| <a name="input_byo_router"></a> [byo\_router](#input\_byo\_router) | Bring your own GCP Compute Router for Service Edge | `bool` | `false` | no |
| <a name="input_byo_router_name"></a> [byo\_router\_name](#input\_byo\_router\_name) | User provided existing GCP Compute Router friendly name | `string` | `null` | no |
| <a name="input_byo_subnet_name"></a> [byo\_subnet\_name](#input\_byo\_subnet\_name) | User provided existing GCP Subnet friendly name | `string` | `null` | no |
| <a name="input_byo_subnets"></a> [byo\_subnets](#input\_byo\_subnets) | Bring your own GCP Subnets for Service Edge | `bool` | `false` | no |
| <a name="input_byo_vpc"></a> [byo\_vpc](#input\_byo\_vpc) | Bring your own GCP VPC for Service Edge | `bool` | `false` | no |
| <a name="input_byo_vpc_name"></a> [byo\_vpc\_name](#input\_byo\_vpc\_name) | User provided existing GCP VPC friendly name | `string` | `null` | no |
| <a name="input_credentials"></a> [credentials](#input\_credentials) | Path to the service account json file for terraform to authenticate to Google Cloud | `string` | n/a | yes |
| <a name="input_enrollment_cert"></a> [enrollment\_cert](#input\_enrollment\_cert) | Get name of ZPA enrollment cert to be used for Service Edge provisioning | `string` | `"Service Edge"` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Custom image name to be used for deploying Service Edge appliances. Ideally all VMs should be on the same Image as templates always pull the latest from Google Marketplace. This variable is provided if a customer desires to override/retain an old ami for existing deployments rather than upgrading and forcing a replacement. It is also inputted as a list to facilitate if a customer desired to manually upgrade select CCs deployed based on the cc\_count index | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name prefix for all your resources | `string` | `"zspse"` | no |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud project name | `string` | n/a | yes |
| <a name="input_provisioning_key_association_type"></a> [provisioning\_key\_association\_type](#input\_provisioning\_key\_association\_type) | Specifies the provisioning key type for Service Edges or ZPA Private Service Edges. The supported values are SERVICE\_EDGE\_GRP and SERVICE\_EDGE\_GRP | `string` | `"SERVICE_EDGE_GRP"` | no |
| <a name="input_provisioning_key_enabled"></a> [provisioning\_key\_enabled](#input\_provisioning\_key\_enabled) | Whether the provisioning key is enabled or not. Default: true | `bool` | `true` | no |
| <a name="input_provisioning_key_max_usage"></a> [provisioning\_key\_max\_usage](#input\_provisioning\_key\_max\_usage) | The maximum number of instances where this provisioning key can be used for enrolling an Service Edge or Service Edge | `number` | `10` | no |
| <a name="input_pse_count"></a> [pse\_count](#input\_pse\_count) | Default number of Service Edge appliances to create per Instance Group/Availability Zone | `number` | `1` | no |
| <a name="input_pse_group_country_code"></a> [pse\_group\_country\_code](#input\_pse\_group\_country\_code) | Optional: Country code of this Service Edge Group. example 'US' | `string` | `"US"` | no |
| <a name="input_pse_group_description"></a> [pse\_group\_description](#input\_pse\_group\_description) | Optional: Description of the Service Edge Group | `string` | `""` | no |
| <a name="input_pse_group_enabled"></a> [pse\_group\_enabled](#input\_pse\_group\_enabled) | Whether this Service Edge Group is enabled or not | `bool` | `true` | no |
| <a name="input_pse_group_latitude"></a> [pse\_group\_latitude](#input\_pse\_group\_latitude) | Latitude of the Service Edge Group. Integer or decimal. With values in the range of -90 to 90 | `string` | `"37.33874"` | no |
| <a name="input_pse_group_location"></a> [pse\_group\_location](#input\_pse\_group\_location) | location of the Service Edge Group in City, State, Country format. example: 'San Jose, CA, USA' | `string` | `"San Jose, CA, USA"` | no |
| <a name="input_pse_group_longitude"></a> [pse\_group\_longitude](#input\_pse\_group\_longitude) | Longitude of the Service Edge Group. Integer or decimal. With values in the range of -90 to 90 | `string` | `"-121.8852525"` | no |
| <a name="input_pse_group_override_version_profile"></a> [pse\_group\_override\_version\_profile](#input\_pse\_group\_override\_version\_profile) | Optional: Whether the default version profile of the Service Edge Group is applied or overridden. Default: false | `bool` | `true` | no |
| <a name="input_pse_group_upgrade_day"></a> [pse\_group\_upgrade\_day](#input\_pse\_group\_upgrade\_day) | Optional: Service Edges in this group will attempt to update to a newer version of the software during this specified day. Default value: SUNDAY. List of valid days (i.e., SUNDAY, MONDAY, etc) | `string` | `"SUNDAY"` | no |
| <a name="input_pse_group_upgrade_time_in_secs"></a> [pse\_group\_upgrade\_time\_in\_secs](#input\_pse\_group\_upgrade\_time\_in\_secs) | Optional: Service Edges in this group will attempt to update to a newer version of the software during this specified time. Default value: 66600. Integer in seconds (i.e., 66600). The integer should be greater than or equal to 0 and less than 86400, in 15 minute intervals | `string` | `"66600"` | no |
| <a name="input_pse_group_version_profile_id"></a> [pse\_group\_version\_profile\_id](#input\_pse\_group\_version\_profile\_id) | Optional: ID of the version profile. To learn more, see Version Profile Use Cases. https://help.zscaler.com/zpa/configuring-version-profile | `string` | `"2"` | no |
| <a name="input_pse_is_public"></a> [pse\_is\_public](#input\_pse\_is\_public) | (Optional) Enable or disable public access for the Service Edge Group. Default value is false | `bool` | `false` | no |
| <a name="input_psevm_instance_type"></a> [psevm\_instance\_type](#input\_psevm\_instance\_type) | Service Edge Instance Type | `string` | `"n2-standard-4"` | no |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region | `string` | n/a | yes |
| <a name="input_subnet_bastion"></a> [subnet\_bastion](#input\_subnet\_bastion) | A subnet IP CIDR for the greenfield/test bastion host in the Management VPC | `string` | `"10.0.0.0/24"` | no |
| <a name="input_subnet_pse"></a> [subnet\_pse](#input\_subnet\_pse) | A subnet IP CIDR for the Service Edge VPC | `string` | `"10.0.1.0/24"` | no |
| <a name="input_tls_key_algorithm"></a> [tls\_key\_algorithm](#input\_tls\_key\_algorithm) | algorithm for tls\_private\_key resource | `string` | `"RSA"` | no |
| <a name="input_use_zscaler_image"></a> [use\_zscaler\_image](#input\_use\_zscaler\_image) | By default, Service Edge will deploy via the Zscaler Latest Image. Setting this to false will deploy the latest Red Hat Enterprise Linux 9 Image instead | `bool` | `true` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | (Optional) Availability zone names. Only required if automatic zones selection based on az\_count is undesirable | `list(string)` | `[]` | no |
| <a name="input_zpa_trusted_network_name"></a> [zpa\_trusted\_network\_name](#input\_zpa\_trusted\_network\_name) | To query trusted network that are associated with a specific Zscaler cloud, it is required to append the cloud name to the name of the trusted network. For more details refer to docs: https://registry.terraform.io/providers/zscaler/zpa/latest/docs/data-sources/zpa_trusted_network | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_testbedconfig"></a> [testbedconfig](#output\_testbedconfig) | Google Cloud Testbed results |
<!-- END_TF_DOCS -->
