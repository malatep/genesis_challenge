# main terraform file used to create all the resource from the corresponding module

# create VPC resources in specified AWS region
module "vpc" {
  source    = "./modules/vpc"
  region    = var.region
  az_number = var.az_number
  providers = {
    aws = aws.DEV # change this value to QA, STAGING or PROD to deploy in different AWS accounts
  }
}

# create Ec2 resources
module "compute" {
  source               = "./modules/compute"
  os                   = var.os
  instance_count       = var.instance_count
  ec2_ebs_volume_count = var.ec2_ebs_volume_count
  public_subnet_id     = module.vpc.public_subnet_id
  public_https_sg_id   = module.vpc.public_https_sg_id
  providers = {
    aws = aws.DEV # change this value to QA, STAGING or PROD to deploy in different AWS accounts
  }
}

# create Networking resources (load balancer and R53 records)
module "networking" {
  source              = "./modules/networking"
  public_subnet_id    = module.vpc.public_subnet_id
  public_alb_sg_id    = module.vpc.public_alb_sg_id
  vpc_id              = module.vpc.vpc_id
  instance_id         = module.compute.instance_id
  instance_private_ip = module.compute.instance_private_ip
  providers = {
    aws = aws.DEV # change this value to QA, STAGING or PROD to deploy in different AWS accounts
  }
}

# create RDS resources
module "database" {
  source            = "./modules/database"
  private_subnet_id = module.vpc.private_subnet_id
  private_db_sg_id  = module.vpc.private_db_sg_id
  rds_multi_az      = var.rds_multi_az
  database_engine   = var.database_engine
  database_class    = var.database_class
  providers = {
    aws = aws.DEV # change this value to QA, STAGING or PROD to deploy in different AWS accounts
  }
}
