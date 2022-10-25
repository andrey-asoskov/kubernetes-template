data "aws_iam_policy_document" "etcd" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "etcd" {
  name               = "${var.solution_short}-${var.env}-etcd"
  path               = "/${var.solution_short}/"
  assume_role_policy = data.aws_iam_policy_document.etcd.json

  tags = {
    Name = "${var.solution_short}-${var.env}-etcd"
  }
}

resource "aws_iam_instance_profile" "etcd" {
  name = "${var.solution_short}-${var.env}-etcd"
  path = "/${var.solution_short}/"
  role = aws_iam_role.etcd.name
}

resource "aws_iam_role_policy_attachment" "etcd_ssm" {
  role       = aws_iam_role.etcd.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "etcd_ec2" {
  role       = aws_iam_role.etcd.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "etcd_s3" {
  role       = aws_iam_role.etcd.name
  policy_arn = aws_iam_policy.access_config_s3_bucket.arn
}
