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

variable "pub_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDP2XUnoUF8cVnjf/VkzIHS2mQ1OzcY/M8Ux3QYSxLgmm48F656Z7ypLydvfC+4hBnxyNNhQ1x261LjEvO323iLjhTj2+BNf5Bh07qepIEw0TH+FpysMVielINILBbcoU/OI3J4+0NWTXufReZ4ZamXNC/pWRDaRBNUxufNIUt9KKw22ZsgyyN0Pk/G/VSTlcw9SthekOUmtdEtR1AA1ZJIhJDmGNEo4g+3vBuDc7ishb9qKW0UeH67mpQS3eUvQEp9pf3kcfcYykr4NpFxIxBOI5RvKqPhtrTm06lzY4xkMO0KQrAro36dF487yg1zXYi1Z/akKkQsjrZqXIxig1l",
  type    = "string"
}

variable "rds_instance_type" {
  default = "db.t2.small"
  type = "string"
}

variable "rds_password" {
  default = "SytcsmDZ"
  type = "string"
}

variable "rds_storage_size"  {
  default=10
  type = "string"
}

variable "rds_username" {
  default="posadero"
  type = "string"
}
