// Control plane
data "aws_iam_policy_document" "control_plane" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "control_plane" {
  name               = "${var.solution_short}-${var.env}-control_plane"
  path               = "/${var.solution_short}/"
  assume_role_policy = data.aws_iam_policy_document.control_plane.json

  tags = {
    Name = "${var.solution_short}-${var.env}-control_plane"
  }
}

resource "aws_iam_instance_profile" "control_plane" {
  name = "${var.solution_short}-${var.env}-control_plane"
  path = "/${var.solution_short}/"
  role = aws_iam_role.control_plane.name
}

// IAM Policy for Control Plane
data "aws_iam_policy_document" "control_plane_control" {
  statement {
    effect = "Allow"
    sid    = "ec2"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeVpcs",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DescribeVolumesModifications",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyVolume",
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteVolume",
      "ec2:DetachVolume",
      "ec2:RevokeSecurityGroupIngress"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    sid    = "autoscalling"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    sid    = "elb"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:AttachLoadBalancerToSubnets",
      "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancerPolicy",
      "elasticloadbalancing:CreateLoadBalancerListeners",
      "elasticloadbalancing:ConfigureHealthCheck",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancerListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DetachLoadBalancerFromSubnets",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerPolicies",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
      "iam:CreateServiceLinkedRole",
      "kms:DescribeKey"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "control_plane_control" {
  name        = "${var.solution}-${var.env}-control_plane_control"
  path        = "/"
  description = "Policy for control_plane_control - ${var.solution}-${var.env}"
  policy      = data.aws_iam_policy_document.control_plane_control.json

  tags = {
    Name = "${var.solution}-${var.env}-control_plane_control"
  }
}

resource "aws_iam_role_policy_attachment" "control_plane_ssm" {
  role       = aws_iam_role.control_plane.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "control_plane_s3" {
  role       = aws_iam_role.control_plane.name
  policy_arn = var.access_config_s3_bucket_arn
}

resource "aws_iam_role_policy_attachment" "control_plane_control" {
  role       = aws_iam_role.control_plane.name
  policy_arn = aws_iam_policy.control_plane_control.arn
}

resource "aws_iam_role_policy_attachment" "control_plane_ebs" {
  role       = aws_iam_role.control_plane.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

// LB
data "aws_iam_policy_document" "lb" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lb" {
  name               = "${var.solution_short}-${var.env}-lb"
  path               = "/${var.solution_short}/"
  assume_role_policy = data.aws_iam_policy_document.lb.json

  tags = {
    Name = "${var.solution_short}-${var.env}-lb"
  }
}

resource "aws_iam_instance_profile" "lb" {
  name = "${var.solution_short}-${var.env}-lb"
  path = "/${var.solution_short}/"
  role = aws_iam_role.lb.name
}

resource "aws_iam_role_policy_attachment" "lb_ssm" {
  role       = aws_iam_role.lb.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "lb_s3" {
  role       = aws_iam_role.lb.name
  policy_arn = var.access_config_s3_bucket_arn
}
