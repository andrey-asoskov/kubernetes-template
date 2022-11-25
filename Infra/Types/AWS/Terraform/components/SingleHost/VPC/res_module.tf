module "VPC" {
  source = "../../../modules/VPC"

  az_count       = var.az_count
  env            = var.env
  solution       = var.solution
  solution_short = var.solution_short
  vpc_cidr_block = lookup(var.vpc_cidr_block, var.env)
}
