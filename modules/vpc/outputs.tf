# VPC module outputs

output "vpc_id" {
  description = "Id of the VPC"
  value       = aws_vpc.challenge_vpc.id
}

output "public_subnet_id" {
  description = "List of public subnet ids"
  value       = aws_subnet.challenge_public_subnet.*.id
}

output "private_subnet_id" {
  description = "List of private subnet ids"
  value       = aws_subnet.challenge_private_subnet.*.id
}

output "public_https_sg_id" {
  description = "Id of the security group used by public Ec2 instances"
  value       = aws_security_group.public_https_sg.id
}

output "private_db_sg_id" {
  description = "Id of the security group used by private RDS database"
  value       = aws_security_group.private_db_sg.id
}

output "public_alb_sg_id" {
  description = "Id of the security group used by the load balancer"
  value       = aws_security_group.public_alb_sg.id
}

