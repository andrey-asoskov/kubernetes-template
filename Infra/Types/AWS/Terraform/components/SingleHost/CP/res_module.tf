module "control_plane" {
  source = "../../../modules/CP-SingleHost"

  env            = var.env
  solution       = var.solution
  solution_short = var.solution_short

  subnets_public_ids = data.terraform_remote_state.VPC.outputs.subnets_public_ids
  security_groups = [
    data.terraform_remote_state.VPC.outputs.sg_etcd_id,
    data.terraform_remote_state.VPC.outputs.sg_control_plane_id,
    data.terraform_remote_state.VPC.outputs.sg_cni-calico_id
  ]
  asg_control_plane_instance_type = var.asg_control_plane_instance_type
  asg_control_plane_DesiredSize   = var.asg_control_plane_DesiredSize
  asg_control_plane_ImageName     = var.asg_control_plane_ImageName
  asg_control_plane_MaxSize       = var.asg_control_plane_MaxSize
  asg_control_plane_MinSize       = var.asg_control_plane_MinSize
  asg_control_plane_shutoff       = var.asg_control_plane_shutoff
  asg_control_plane_backup        = var.asg_control_plane_backup
}
