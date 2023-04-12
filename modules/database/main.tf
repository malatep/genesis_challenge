# module to create RDS resources

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0" #locking to specific version
    }
  }
}

# db subnet group
resource "aws_db_subnet_group" "challenge_rds_subnet_group" {
  name       = "challenge_rds_subnet_group"
  subnet_ids = var.private_subnet_id
}

# RDS instance in private subnets
resource "aws_db_instance" "challege_rds_sql_server" {
  allocated_storage      = 20
  identifier             = "challege-rds-sqlserver"
  engine                 = var.database_engine
  engine_version         = "15.00"
  instance_class         = var.database_class
  username               = "admin"
  db_subnet_group_name   = aws_db_subnet_group.challenge_rds_subnet_group.name
  vpc_security_group_ids = [var.private_db_sg_id]
  multi_az               = var.rds_multi_az
  skip_final_snapshot    = true
  # enable managing the master password with Secrets Manager
  manage_master_user_password = true
}

