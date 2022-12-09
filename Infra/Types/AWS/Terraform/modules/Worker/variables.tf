variable "env" {
  description = "Name of an environment"
  type        = string
}

variable "solution" {
  description = "Name of a solution"
  type        = string
}

variable "solution_short" {
  description = "Short name of a solution"
  type        = string
}

// VPC config
variable "security_groups" {
  type        = list(string)
  description = "List of Security Groups"
}

variable "subnets_public_ids" {
  type        = list(string)
  description = "subnets public ids"
}

// ASG config for worker
variable "asg_worker_instance_type" {
  description = "Desired instance type for ASG"
  type        = string
}

variable "asg_worker_DesiredSize" {
  description = "Desired size for ASG"
  type        = number
}


variable "asg_worker_ImageName" {
  description = "Image Name for the worker AMI"
  type        = string
}

variable "asg_worker_MaxSize" {
  description = "Max size for ASG"
  type        = number
}

variable "asg_worker_MinSize" {
  description = "Min size for ASG"
  type        = number
}

variable "asg_worker_shutoff" {
  description = "IF there is a need to shut EC2 off via automation"
  type        = string
}

variable "asg_worker_backup" {
  description = "IF there is a need to backup EC2 via automation"
  type        = string
}

variable "config_bucket_id" {
  description = "Config bucket id"
  type        = string
}

variable "access_config_s3_bucket_arn" {
  description = "Config bucket access IAM policy arn"
  type        = string
}
