output "s3_config-bucket_id" {
  value       = module.control_plane.s3_config-bucket_id
  description = "Config Bucker ID"
}

output "access_config_s3_bucket_arn" {
  value       = module.control_plane.access_config_s3_bucket_arn
  description = "IAM Policy ARN"
}
