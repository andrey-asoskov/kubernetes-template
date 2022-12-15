// Etcd
resource "aws_security_group" "etcd" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.solution_short}-${var.env}-etcd"
  description = "Security group for Etcd - ${var.solution}-${var.env}"

  tags = {
    Name = "${var.solution_short}-${var.env}-etcd"
  }
}

resource "aws_security_group_rule" "etcd_members_IN" {
  type                     = "ingress"
  description              = "Allow incomming Etcd connections between members"
  from_port                = 2379
  to_port                  = 2380
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.etcd.id
  security_group_id        = aws_security_group.etcd.id
}

resource "aws_security_group_rule" "etcd_control_plane_IN" {
  type                     = "ingress"
  description              = "Allow incomming Etcd connections from control plane"
  from_port                = 2379
  to_port                  = 2380
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.control_plane.id
  security_group_id        = aws_security_group.etcd.id
}

resource "aws_security_group_rule" "etcd_OUT" { #tfsec:ignore:aws-vpc-no-public-egress-sgr
  type              = "egress"
  description       = "Allow Etcd to access Internet"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.etcd.id
}

//Control Plane
resource "aws_security_group" "control_plane" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.solution_short}-${var.env}-control_plane"
  description = "Security group for Control plane - ${var.solution}-${var.env}"

  tags = {
    Name                               = "${var.solution_short}-${var.env}-control_plane"
    "kubernetes.io/cluster/${var.env}" = "owned"
  }
}

resource "aws_security_group_rule" "control_plane_IN" { #tfsec:ignore:aws-ec2-no-public-ingress-sgr #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  type              = "ingress"
  description       = "Allow incomming connections to control plane"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "control_plane_IN_lb" {
  type                     = "ingress"
  description              = "Allow incomming connections from lb"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id
  security_group_id        = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "control_plane_workers_IN" {
  type                     = "ingress"
  description              = "Allow incomming connections from workers"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "control_plane_metrics_IN" {
  type                     = "ingress"
  description              = "Allow incomming connections to get metrics"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "control_plane_members_IN" {
  type                     = "ingress"
  description              = "Allow incomming connections to control plane"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  source_security_group_id = aws_security_group.control_plane.id
  security_group_id        = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "control_plane_OUT" { #tfsec:ignore:aws-vpc-no-public-egress-sgr
  type              = "egress"
  description       = "Allow Control Plane to access Internet"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.control_plane.id
}

//LB 
resource "aws_security_group" "lb" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.solution_short}-${var.env}-lb"
  description = "Security group for lb - ${var.solution}-${var.env}"

  tags = {
    Name = "${var.solution_short}-${var.env}-lb"
  }
}

resource "aws_security_group_rule" "lb_IN" { #tfsec:ignore:aws-ec2-no-public-ingress-sgr #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  type              = "ingress"
  description       = "Allow incomming connections to lb"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb_OUT" { #tfsec:ignore:aws-vpc-no-public-egress-sgr
  type              = "egress"
  description       = "Allow lb to access Internet"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
} 

// Worker
resource "aws_security_group" "worker" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.solution_short}-${var.env}-worker"
  description = "Security group for worker - ${var.solution}-${var.env}"

  tags = {
    Name                               = "${var.solution_short}-${var.env}-worker"
    "kubernetes.io/cluster/${var.env}" = "owned"
  }
}

/* resource "aws_security_group_rule" "worker_IN" { #tfsec:ignore:aws-vpc-no-public-ingress-sgr tfsec:ignore:aws-ec2-no-public-ingress-sgr
  type              = "ingress"
  description       = "Allow incomming connections to worker"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
} */

resource "aws_security_group_rule" "worker_members_IN" {
  type                     = "ingress"
  description              = "Allow incomming connections to worker"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_control_plane_IN" {
  type                     = "ingress"
  description              = "Allow incomming connections to worker"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.control_plane.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_OUT" { #tfsec:ignore:aws-vpc-no-public-egress-sgr
  type              = "egress"
  description       = "Allow Control Plane to access Internet"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

// CNI-Calico
resource "aws_security_group" "cni-calico" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.solution_short}-${var.env}-cni-calico"
  description = "Security group for CNI Calico - ${var.solution}-${var.env}"

  tags = {
    Name                               = "${var.solution_short}-${var.env}-cni-calico"
    "kubernetes.io/cluster/${var.env}" = "owned"
  }
}

resource "aws_security_group_rule" "cni-calico_BGP_IN" {
  type                     = "ingress"
  description              = "Allow incomming BGP connections"
  from_port                = 179
  to_port                  = 179
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cni-calico.id
  security_group_id        = aws_security_group.cni-calico.id
}

resource "aws_security_group_rule" "cni-calico_IP-in-IP_IN" {
  type                     = "ingress"
  description              = "Allow incomming IP-in-IP connections"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "4"
  source_security_group_id = aws_security_group.cni-calico.id
  security_group_id        = aws_security_group.cni-calico.id
}

resource "aws_security_group_rule" "cni-calico_VXLAN_IN" {
  type                     = "ingress"
  description              = "Allow incomming VXLAN connections"
  from_port                = 4789
  to_port                  = 4789
  protocol                 = "udp"
  source_security_group_id = aws_security_group.cni-calico.id
  security_group_id        = aws_security_group.cni-calico.id
}

resource "aws_security_group_rule" "cni-calico_Typha_IN" {
  type                     = "ingress"
  description              = "Allow incomming Typha connections"
  from_port                = 5473
  to_port                  = 5473
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cni-calico.id
  security_group_id        = aws_security_group.cni-calico.id
}

resource "aws_security_group_rule" "cni-calico_Wireguard_IN" {
  type                     = "ingress"
  description              = "Allow incomming Wireguard connections"
  from_port                = 51820
  to_port                  = 51821
  protocol                 = "udp"
  source_security_group_id = aws_security_group.cni-calico.id
  security_group_id        = aws_security_group.cni-calico.id
}

resource "aws_security_group_rule" "cni-calico_BGP_OUT" {
  type                     = "egress"
  description              = "Allow outgoing BGP connections"
  from_port                = 179
  to_port                  = 179
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cni-calico.id
  security_group_id        = aws_security_group.cni-calico.id
}

resource "aws_security_group_rule" "cni-calico_IP-in-IP_OUT" {
  type                     = "egress"
  description              = "Allow outgoing IP-in-IP connections"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "4"
  source_security_group_id = aws_security_group.cni-calico.id
  security_group_id        = aws_security_group.cni-calico.id
}

resource "aws_security_group_rule" "cni-calico_VXLAN_OUT" {
  type                     = "egress"
  description              = "Allow outgoing VXLAN connections"
  from_port                = 4789
  to_port                  = 4789
  protocol                 = "udp"
  source_security_group_id = aws_security_group.cni-calico.id
  security_group_id        = aws_security_group.cni-calico.id
}

resource "aws_security_group_rule" "cni-calico_Wireguard_OUT" {
  type                     = "egress"
  description              = "Allow outgoing Wireguard connections"
  from_port                = 51820
  to_port                  = 51821
  protocol                 = "udp"
  source_security_group_id = aws_security_group.cni-calico.id
  security_group_id        = aws_security_group.cni-calico.id
}
