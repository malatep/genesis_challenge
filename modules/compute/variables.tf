# variables used by compute module

variable "os" {}

variable "ec2_ebs_volume_count" {}

variable "instance_count" {}

variable "ec2_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Ec2 instance type"
  validation {
    condition     = var.ec2_instance_type == "t3.medium"
    error_message = "Only Ec2 instance type t3.medium is supported"
  }
}

variable "ec2_ebs_volume_size" {
  type        = number
  default     = 50
  description = "Size of the EBS hard drive volumes"
  validation {
    condition     = var.ec2_ebs_volume_size == 50
    error_message = "Valid volume size is 50"
  }
}

variable "ec2_device_names" {
  type        = list(string)
  description = "Name of the hard drive volumes"
  default = [
    "/dev/sdd",
    "/dev/sde",
    "/dev/sdf",
    "/dev/sdg",
    "/dev/sdh",
  ]
}

variable "public_subnet_id" {
  type        = list(string)
  description = "List of public subnet ids"
}

variable "public_https_sg_id" {
  type        = string
  description = "Id of the security group allowing traffic to the public Ec2 instances"
}

