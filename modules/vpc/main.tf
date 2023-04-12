# module to create VPC resources

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0" #locking to specific version
    }
  }
}

# retrieve available AZs for the given region
data "aws_availability_zones" "available" {}

# create VPC 
resource "aws_vpc" "challenge_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "challenge_vpc"
  }
}

# create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.challenge_vpc.id

  tags = {
    Name = "challenge_igw"
  }
}

# create N public subnets 
resource "aws_subnet" "challenge_public_subnet" {
  count             = var.az_number
  vpc_id            = aws_vpc.challenge_vpc.id
  cidr_block        = "10.0.${10 + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "challenge_public_subnet_${count.index + 1}"
  }
}

# create N private subnets 
resource "aws_subnet" "challenge_private_subnet" {
  count             = var.az_number
  vpc_id            = aws_vpc.challenge_vpc.id
  cidr_block        = "10.0.${20 + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "challenge_private_subnet_${count.index + 1}"
  }
}

# create route table for public subnet. Has a route to the IGW to allow traffic to the public internet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.challenge_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "challenge_public_subnet_route_table"
  }
}

# create route table for private subnet. Has only the default route, mapping the VPC's CIDR block to "local"
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.challenge_vpc.id

  tags = {
    Name = "challenge_private_subnet_route_table"
  }
}

# associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.challenge_public_subnet)
  subnet_id      = element(aws_subnet.challenge_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.challenge_private_subnet)
  subnet_id      = element(aws_subnet.challenge_private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

#security group for public instance 
resource "aws_security_group" "public_https_sg" {
  name        = "public_https_sg"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.challenge_vpc.id

  ingress {
    description      = "allow TLS from everywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "public_https_sg"
  }
}

#security group for RDS instance 
resource "aws_security_group" "private_db_sg" {
  name        = "private_db_sg"
  description = "Allow traffic on port 1433 from Ec2"
  vpc_id      = aws_vpc.challenge_vpc.id

  ingress {
    description     = "allow TCP on port 1443 from Ec2"
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_security_group.public_https_sg.id]
  }

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_db_sg"
  }
}

#security group for ALB 
resource "aws_security_group" "public_alb_sg" {
  name        = "public_alb_sg"
  description = "Allow inbound public traffic"
  vpc_id      = aws_vpc.challenge_vpc.id

  ingress {
    description = "Allow HTTP inbound traffic on the load balancer listener port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    description     = "allow outbound traffic to Ec2 instances"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.public_https_sg.id]
  }

  tags = {
    Name = "public_alb_sg"
  }
}