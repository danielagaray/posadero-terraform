#
# Variables Configuration
#

variable "cluster-name" {
  default = "eks-posadera"
  type    = "string"
}

variable "region" {
  default = "us-east-1"
  type    = "string"
}

variable "asg_min_size" {
  default = 1
}

variable "asg_max_size" {
  default = 1
}

variable "asg_desired_size" {
  default = 1
}

variable "asg_instance_type_size" {
  default = "t2.large",
  type    = "string"
}

variable "jump_instance_type" {
  default = "t1.micro",
  type    = "string"
}
