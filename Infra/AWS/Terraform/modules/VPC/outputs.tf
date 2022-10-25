// VPC
output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "VPC id"
}

// Subnets
output "subnets_private_ids" {
  value       = aws_subnet.private[*].id
  description = "Private subnets ids"
}

output "subnets_public_ids" {
  value       = aws_subnet.public[*].id
  description = "Public subnets ids"
}

//Security Groups
output "sg_etcd_id" {
  value       = aws_security_group.etcd.id
  description = "Etcd security group id"
}

output "sg_control_plane_id" {
  value       = aws_security_group.control_plane.id
  description = "Control plane security group id"
}

output "sg_lb_id" {
  value       = aws_security_group.lb.id
  description = "lb security group id"
}

output "sg_worker_id" {
  value       = aws_security_group.worker.id
  description = "worker security group id"
}
