# input variables required to create the infrastructure

variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "Name of the AWS Region where resources will be created"
  validation {
    condition     = can(regex("(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-\\d", var.region))
    error_message = "Must be valid AWS Region."
  }
}

variable "az_number" {
  type        = number
  default     = 2
  description = "Number of AZs in use"
  validation {
    condition     = var.az_number == 2 || var.az_number == 3
    error_message = "Minimun 2 and Maximum 3 AZs can be specified"
  }
}

variable "os" {
  type        = string
  default     = "Linux"
  description = "Operating system of the Ec2 instance"
  validation {
    condition     = var.os == "Linux" || var.os == "Windows"
    error_message = "Valid values are Linux or Windows"
  }
}

variable "ec2_ebs_volume_count" {
  type        = number
  default     = 2
  description = "Number of hard drive volumes attached to each Ec2 instance"
  validation {
    condition     = var.ec2_ebs_volume_count > 0 && var.ec2_ebs_volume_count <= 5
    error_message = "Valid values are between 1 and 5"
  }
}

variable "instance_count" {
  type        = number
  default     = 1
  description = "Number of Ec2 instance to be created"
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Valid values are between 1 and 10"
  }
}

variable "database_engine" {
  type        = string
  default     = "sqlserver-web"
  description = "SQL Server Database engine"
  validation {
    condition     = var.database_engine == "sqlserver-web"
    error_message = "Only SQL Server Web engine supported as it supports t3.large and t3.medium"
  }
}

variable "database_class" {
  type        = string
  default     = "db.t3.medium"
  description = "SQL Server Database engine class"
  validation {
    condition     = var.database_class == "db.t3.medium" || var.database_class == "db.t3.large"
    error_message = "Only 't3.medium' or 't3.large' supported"
  }
}

variable "rds_multi_az" {
  type        = bool
  default     = false
  description = "SQL Server Database multi AZ deployment"
  validation {
    condition     = var.rds_multi_az == false
    error_message = "Multi-AZ instances are not available for engine sqlserver-web"
  }
}