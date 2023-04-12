# Database module outputs

output "rds_database_name" {
  description = "Name of the SQL Server RDS Database"
  value       = aws_db_instance.challege_rds_sql_server.identifier
}

output "rds_endpoint" {
  description = "Endpoint of the RDS Database"
  value       = aws_db_instance.challege_rds_sql_server.address
}

output "rds_port" {
  description = "The port on which the DB accepts connections"
  value       = aws_db_instance.challege_rds_sql_server.port
}

output "rds_master_username" {
  description = "Username for the master DB user"
  value       = aws_db_instance.challege_rds_sql_server.username
}