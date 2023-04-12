output "ec2_instance_id" {
  description = "Id of EC2 instance(s)"
  value       = module.compute.instance_id
}

output "ec2_instance_private_ip" {
  description = "Private IP of EC2 instance(s)"
  value       = module.compute.instance_private_ip
}

output "load_balancer_dns_name" {
  description = "Load balancer DNS name"
  value       = module.networking.load_balancer_dns_name
}

output "rds_database_name" {
  description = "Name of the SQL Server RDS Database"
  value       = module.database.rds_database_name
}

output "rds_endpoint" {
  description = "Endpoint of the RDS Database"
  value       = module.database.rds_endpoint
}

output "rds_port" {
  description = "The port on which the DB accepts connections"
  value       = module.database.rds_port
}

output "rds_master_username" {
  description = "Username for the master DB user"
  value       = module.database.rds_master_username
}