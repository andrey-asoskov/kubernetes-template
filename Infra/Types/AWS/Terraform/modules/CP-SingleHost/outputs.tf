output "s3_config-bucket_id" {
  value       = aws_s3_bucket.config_bucket.id
  description = "Config Bucker ID"
}

output "access_config_s3_bucket_arn" {
  value       = aws_iam_policy.access_config_s3_bucket.arn
  description = "IAM Policy ARN"
}
