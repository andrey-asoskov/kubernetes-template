data "aws_iam_policy_document" "worker" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "worker" {
  name               = "${var.solution_short}-${var.env}-worker"
  path               = "/${var.solution_short}/"
  assume_role_policy = data.aws_iam_policy_document.worker.json

  tags = {
    Name = "${var.solution_short}-${var.env}-worker"
  }
}


// IAM Policy for Control Plane
data "aws_iam_policy_document" "worker_control" {
  statement {
    effect = "Allow"
    sid    = "ec2"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "worker_control" {
  name        = "${var.solution}-${var.env}-worker_control"
  path        = "/"
  description = "Policy for control_plane_control - ${var.solution}-${var.env}"
  policy      = data.aws_iam_policy_document.worker_control.json

  tags = {
    Name = "${var.solution}-${var.env}-worker_control"
  }
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.solution_short}-${var.env}-worker"
  path = "/${var.solution_short}/"
  role = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "worker_ssm" {
  role       = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "worker_s3" {
  role       = aws_iam_role.worker.name
  policy_arn = var.access_config_s3_bucket_arn
}

resource "aws_iam_role_policy_attachment" "worker_control" {
  role       = aws_iam_role.worker.name
  policy_arn = aws_iam_policy.worker_control.arn
}

resource "aws_iam_role_policy_attachment" "worker_ebs" {
  role       = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
