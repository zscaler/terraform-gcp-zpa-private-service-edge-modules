output "vpc_network" {
  description = "Service Edge VPC ID"
  value       = try(google_compute_network.vpc_network[0].self_link, data.google_compute_network.vpc_network_selected[0].self_link)
}

output "vpc_network_name" {
  description = "Service Edge VPC Name"
  value       = try(google_compute_network.vpc_network[0].name, data.google_compute_network.vpc_network_selected[0].name)
}

output "pse_subnet" {
  description = "Service Edge VPC Subnetwork ID"
  value       = try(google_compute_subnetwork.vpc_subnet_pse[0].self_link, data.google_compute_subnetwork.vpc_subnet_pse_selected[0].self_link)
}

output "bastion_subnet" {
  description = "Subnet for the bastion host"
  value       = google_compute_subnetwork.vpc_subnet_bastion[*].self_link
}

output "vpc_nat_gateway" {
  description = "Service Edge VPC Cloud NAT Gateway ID"
  value       = try(google_compute_router_nat.vpc_nat_gateway[0].id, data.google_compute_router_nat.vpc_nat_gateway_selected[0].id, null)
}
