terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "visitor_counter_sg" {
  name        = "visitor-counter-sg"
  description = "Allow HTTP and SSH"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "visitor-counter-sg"
  }
}

resource "aws_instance" "visitor_counter" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.visitor_counter_sg.id]

  user_data = templatefile("${path.module}/user_data.sh", {
    dockerhub_user = var.dockerhub_user
    image_version  = var.image_version
  })

  tags = {
    Name = "visitor-counter-ec2"
  }
}

resource "aws_eip" "visitor_counter_ip" {
  domain = "vpc"

  tags = {
    Name = "visitor-counter-eip"
  }
}

resource "aws_eip_association" "visitor_counter_assoc" {
  instance_id   = aws_instance.visitor_counter.id
  allocation_id = aws_eip.visitor_counter_ip.id
}
