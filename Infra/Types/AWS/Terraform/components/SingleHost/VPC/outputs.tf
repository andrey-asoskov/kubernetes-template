// VPC
output "vpc_id" {
  value       = module.VPC.vpc_id
  description = "VPC id"
}

// Subnets
output "subnets_private_ids" {
  value       = module.VPC.subnets_private_ids
  description = "Private subnets ids"
}

output "subnets_public_ids" {
  value       = module.VPC.subnets_public_ids
  description = "Public subnets ids"
}

//Security Groups
output "sg_etcd_id" {
  value       = module.VPC.sg_etcd_id
  description = "Etcd security group id"
}

output "sg_control_plane_id" {
  value       = module.VPC.sg_control_plane_id
  description = "Control plane security group id"
}

output "sg_lb_id" {
  value       = module.VPC.sg_lb_id
  description = "lb security group id"
}

output "sg_worker_id" {
  value       = module.VPC.sg_worker_id
  description = "worker security group id"
}
