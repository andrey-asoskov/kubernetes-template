variable "aws_region" {
  description = "AWS region to spin up the infra"
  type        = map(string)
  default = {
    "dev"     = "us-east-1"
    "staging" = "us-east-1"
    "prod"    = "us-east-1"
    "prod-uk" = "eu-west-2"
  }
}

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
// ASG config for Worker
variable "asg_worker_instance_type" {
  description = "Desired instance types for ASG"
  type        = string
}

variable "asg_worker_ImageName" {
  description = "Image Name for the worker"
  type        = string
}

variable "asg_worker_MinSize" {
  description = "Min size for ASG"
  type        = number
}

variable "asg_worker_MaxSize" {
  description = "Max size for ASG"
  type        = number
}

variable "asg_worker_DesiredSize" {
  description = "Desired size for ASG"
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
