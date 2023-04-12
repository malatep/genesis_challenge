# Networking module outputs

output "load_balancer_dns_name" {
  description = "Load balancer DNS name"
  value       = aws_lb.load_balaner.dns_name
}
