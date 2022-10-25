data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "config_bucket" {
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.config_bucket.arn,
      "${aws_s3_bucket.config_bucket.arn}/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
      ]
    }
  }
}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.solution_short}-${var.env}"

  tags = {
    Name = "${data.aws_caller_identity.current.account_id}-${var.solution_short}-${var.env}"
  }
}

resource "aws_s3_bucket_policy" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  policy = data.aws_iam_policy_document.config_bucket.json
}

resource "aws_s3_bucket_acl" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "archive_file" "scripts" {
  type        = "zip"
  source_dir  = "${path.module}/../../../scripts/"
  output_path = "${path.module}/../../../scripts.zip"
}

resource "aws_s3_object" "scripts" {
  bucket      = aws_s3_bucket.config_bucket.id
  key         = "scripts.zip"
  source      = data.archive_file.scripts.output_path
  source_hash = data.archive_file.scripts.output_base64sha256

  tags = {
    Name = "${var.solution_short}-${var.env}-scripts"
  }
}

// IAM Policy to access config bucket

data "aws_iam_policy_document" "access_config_s3_bucket" {
  statement {
    effect = "Allow"
    sid    = "s3buckets"
    actions = [
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}"
    ]
  }

  statement {
    effect = "Allow"
    sid    = "s3objects"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}/*"
    ]
  }
}

resource "aws_iam_policy" "access_config_s3_bucket" {
  name        = "${var.solution}-${var.env}-access_config_s3_bucket"
  path        = "/"
  description = "Policy to download files from config bucket for - ${var.solution}-${var.env}"
  policy      = data.aws_iam_policy_document.access_config_s3_bucket.json

  tags = {
    Name = "${var.solution}-${var.env}-access_config_s3_bucket"
  }
}
