resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name                               = "${var.solution_short}-${var.env}-vpc"
    "kubernetes.io/cluster/${var.env}" = "owned"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.solution_short}-${var.env}-default"
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id

  tags = {
    Name = "${var.solution_short}-${var.env}-default"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name                               = "${var.solution_short}-${var.env}-igw"
    "kubernetes.io/cluster/${var.env}" = "owned"
  }
}
