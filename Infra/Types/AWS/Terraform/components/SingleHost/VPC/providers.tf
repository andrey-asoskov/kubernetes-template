provider "aws" {
  region  = lookup(var.aws_region, var.env)
  profile = "flashslash"
  default_tags {
    tags = {
      Solution    = var.solution
      Environment = var.env
    }
  }
}
