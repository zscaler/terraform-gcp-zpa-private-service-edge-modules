locals {
  testbedconfig = <<TB
GCP Project Name:
${module.pse_vm.instance_template_project}

GCP Region:
${module.pse_vm.instance_template_region}

GCP VPC Network:
${module.network.vpc_network}

GCP Availability Zones:
${join("\n", module.pse_vm.instance_group_zones)}

Instance Group Names:
${join("\n", module.pse_vm.instance_group_names)}

All Service Edge Instance IPs:
${join("\n", module.pse_vm.pse_private_ip)}
TB
}

output "testbedconfig" {
  description = "Google Cloud Testbed results"
  value       = local.testbedconfig
}

resource "local_file" "testbed" {
  content  = local.testbedconfig
  filename = "./testbed.txt"
}
