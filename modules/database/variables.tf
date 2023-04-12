# variables used by compute module

variable "database_engine" {}

variable "database_class" {}

variable "rds_multi_az" {}

variable "private_subnet_id" {
  type        = list(string)
  description = "List of private subnet ids"
}

variable "private_db_sg_id" {
  type        = string
  description = "Id of the security group allowing traffic to RDS from Ec2"
}


  