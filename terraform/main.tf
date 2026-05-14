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

# -----------------------------
# AMI
# -----------------------------
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

# -----------------------------
# SECURITY GROUP
# -----------------------------
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
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

# -----------------------------
# ALB 
# -----------------------------

resource "aws_lb" "visitor_counter_alb" {
  name               = "visitor-counter-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.visitor_counter_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "visitor-counter-alb"
  }
}

# -----------------------------
# TARGET GROUP USED BY THE AUTO SCALING GROUP
# -----------------------------

resource "aws_lb_target_group" "visitor_counter_tg" {
  name     = "visitor-counter-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "visitor-counter-tg"
  }
}

# -----------------------------
# Listener
# -----------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.visitor_counter_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# -----------------------------
# 🚀 LAUNCH TEMPLATE
# -----------------------------
resource "aws_launch_template" "visitor_counter_lt" {
  name_prefix   = "visitor-counter-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.visitor_counter_sg.id
  ]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    dockerhub_user = var.dockerhub_user
    image_version  = var.image_version
    redis_host     = var.redis_host
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "visitor-counter-asg-instance"
    }
  }
}

# -----------------------------
# 🚀 AUTO SCALING GROUP
# -----------------------------
resource "aws_autoscaling_group" "visitor_counter_asg" {
  name                = "visitor-counter-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = var.subnet_ids

  target_group_arns = [
    aws_lb_target_group.visitor_counter_tg.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.visitor_counter_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "visitor-counter-asg-instance"
    propagate_at_launch = true
  }
}

# -----------------------------
# AUTO SCALING POLICY - ALB REQUESTS
# -----------------------------

resource "aws_autoscaling_policy" "visitor_counter_request_scaling" {
  name                   = "visitor-counter-request-count-scaling"
  autoscaling_group_name = aws_autoscaling_group.visitor_counter_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"

      resource_label = "${aws_lb.visitor_counter_alb.arn_suffix}/${aws_lb_target_group.visitor_counter_tg.arn_suffix}"
    }

    target_value = 5
  }
}

# -----------------------------
# Route 53
# -----------------------------

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.visitor_counter_alb.dns_name
    zone_id                = aws_lb.visitor_counter_alb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.visitor_counter_alb.dns_name
    zone_id                = aws_lb.visitor_counter_alb.zone_id
    evaluate_target_health = false
  }
}

data "aws_acm_certificate" "visitor_counter_cert" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.visitor_counter_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.visitor_counter_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.visitor_counter_tg.arn
  }
}


