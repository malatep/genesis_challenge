# Compute module outputs

output "instance_private_ip" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.ec2_instance.*.private_ip
}

output "instance_id" {
  description = "Id of EC2 instance"
  value       = aws_instance.ec2_instance.*.id
}
