# module to create networking resources

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0" #locking to specific version
    }
  }
}

# create public application load balancer
resource "aws_lb" "load_balaner" {
  name               = "challenge-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_alb_sg_id]
  subnets            = var.public_subnet_id
}

# create target group 
resource "aws_lb_target_group" "target_group_https" {
  name     = "alb-tg-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
}

# associate Ec2 instances to target group
resource "aws_lb_target_group_attachment" "tg_instance_attachment" {
  count            = length(var.instance_id)
  target_group_arn = aws_lb_target_group.target_group_https.arn
  target_id        = element(var.instance_id, count.index)
  port             = 443
}

# create ALB listener on port 80 to the Ec2 target group
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.load_balaner.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_https.arn
  }
}

# create private hosted zone to host the DNS records
resource "aws_route53_zone" "private_hz" {
  name = "challenge.genesisahc.ie"

  vpc {
    vpc_id = var.vpc_id
  }
}

# create record to the server Private IP address
resource "aws_route53_record" "instance_private_ip_record" {
  zone_id = aws_route53_zone.private_hz.zone_id
  name    = "instance.challenge.genesisahc.ie"
  type    = "A"
  ttl     = 300
  records = var.instance_private_ip
}

# create record to the ALB DNS name
resource "aws_route53_record" "alb_domain_record" {
  zone_id = aws_route53_zone.private_hz.zone_id
  name    = "lb.challenge.genesisahc.ie"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.load_balaner.dns_name]
}