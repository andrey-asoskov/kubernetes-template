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
variable "sg_etcd_id" {
  type        = string
  description = "SG Etcd id"
}

variable "subnets_public_ids" {
  type        = list(string)
  description = "subnets public ids"
}

// ASG config
variable "asg_etcd_instance_type" {
  description = "Desired instance type for ASG"
  type        = string
}

variable "asg_etcd_DesiredSize" {
  description = "Desired size for ASG"
  type        = number
}

variable "asg_etcd_ImageName" {
  description = "Image Name for the Etcd AMI"
  type        = string
}

variable "asg_etcd_MaxSize" {
  description = "Max size for ASG"
  type        = number
}

variable "asg_etcd_MinSize" {
  description = "Min size for ASG"
  type        = number
}

variable "asg_etcd_shutoff" {
  description = "IF there is a need to shut EC2 off via automation"
  type        = string
}

variable "asg_etcd_backup" {
  description = "IF there is a need to backup EC2 via automation"
  type        = string
}
