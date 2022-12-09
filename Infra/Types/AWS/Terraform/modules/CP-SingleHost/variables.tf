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

// ASG config for Control Plane
variable "asg_control_plane_instance_type" {
  description = "Desired instance type for ASG"
  type        = string
}

variable "asg_control_plane_DesiredSize" {
  description = "Desired size for ASG"
  type        = number
}

variable "asg_control_plane_ImageName" {
  description = "Image Name for the Control Plane AMI"
  type        = string
}

variable "asg_control_plane_MaxSize" {
  description = "Max size for ASG"
  type        = number
}

variable "asg_control_plane_MinSize" {
  description = "Min size for ASG"
  type        = number
}

variable "asg_control_plane_shutoff" {
  description = "IF there is a need to shut EC2 off via automation"
  type        = string
}

variable "asg_control_plane_backup" {
  description = "IF there is a need to backup EC2 via automation"
  type        = string
}
