# variables used by networking module

variable "public_subnet_id" {
  type        = list(string)
  description = "List of public subnet ids"
}

variable "public_alb_sg_id" {
  type        = string
  description = "Id of the security group allowing traffic to/from load balancer"
}

variable "vpc_id" {
  type        = string
  description = "Id of the VPC"
}

variable "instance_id" {
  type        = list(string)
  description = "List of Ec2 intances Id"
}

variable "instance_private_ip" {
  type        = list(string)
  description = "List of Ec2 intances Private IPs"
}
