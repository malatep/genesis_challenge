# module to create Ec2 resources

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0" #locking to specific version
    }
  }
}

# retrieve available AZs 
data "aws_availability_zones" "available" {}

# retrieve the latest Amazon Linux 2 or Windows Server 2022 AMI that will be used to create Ec2 instance
data "aws_ssm_parameter" "ec2_AMI_image" {
  name = var.os == "Linux" ? "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2" : "/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base"
}


# create IAM role that will be used by the Ec2 instance to allow connection using SSM (this allows to SSH into the intance without the need to open port 22)
resource "aws_iam_role" "ec2_ssm_role" {

  name = "ec2_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

  tags = {
    "Name" = "ec2_ssm_role"
  }

}

# create Ec2 instance profile with SSM role
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2_ssm_profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# create Ec2 instance
resource "aws_instance" "ec2_instance" {
  count = var.instance_count
  ami   = data.aws_ssm_parameter.ec2_AMI_image.value
  # if count > 1, this allows to deploy multiple EC2 instances across the available subnets
  subnet_id                   = tolist(var.public_subnet_id)[count.index % length(var.public_subnet_id)]
  instance_type               = var.ec2_instance_type
  vpc_security_group_ids      = [var.public_https_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
  associate_public_ip_address = true

  tags = {
    Name = "public_instance_${count.index + 1}"
  }
}

# create EBS volumes 
resource "aws_ebs_volume" "ebs_volume" {
  count             = var.instance_count * var.ec2_ebs_volume_count
  availability_zone = element(aws_instance.ec2_instance.*.availability_zone, floor(count.index / var.ec2_ebs_volume_count))
  size              = var.ec2_ebs_volume_size
}

# attach EBS volumes to Ec2
resource "aws_volume_attachment" "volume_attachement" {
  count       = var.instance_count * var.ec2_ebs_volume_count
  volume_id   = aws_ebs_volume.ebs_volume.*.id[count.index]
  device_name = element(var.ec2_device_names, count.index)
  instance_id = element(aws_instance.ec2_instance.*.id, floor(count.index / var.ec2_ebs_volume_count))
}