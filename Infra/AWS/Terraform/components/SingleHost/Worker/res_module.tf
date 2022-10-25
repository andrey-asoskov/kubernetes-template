module "worker" {
  source = "../../../modules/Worker"

  env            = var.env
  solution       = var.solution
  solution_short = var.solution_short

  subnets_public_ids = data.terraform_remote_state.VPC.outputs.subnets_public_ids
  sg_worker_id       = data.terraform_remote_state.VPC.outputs.sg_control_plane_id

  asg_worker_instance_type = var.asg_worker_instance_type
  asg_worker_DesiredSize   = var.asg_worker_DesiredSize
  asg_worker_ImageName     = var.asg_worker_ImageName
  asg_worker_MaxSize       = var.asg_worker_MaxSize
  asg_worker_MinSize       = var.asg_worker_MinSize
  asg_worker_shutoff       = var.asg_worker_shutoff
  asg_worker_backup        = var.asg_worker_backup

  config_bucket_id            = data.terraform_remote_state.CP.outputs.s3_config-bucket_id
  access_config_s3_bucket_arn = data.terraform_remote_state.CP.outputs.access_config_s3_bucket_arn
}
