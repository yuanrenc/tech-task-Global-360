# Alternative Architecture: ALB + ASG
# This file demonstrates the ideal architecture with self-healing capabilities
# Cost: ~$71 /month (ALB $18 + 2x t2.nano $8 + NAT Gateway $45)

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr_block  = var.vpc_cidr_block
  private_subnets = var.private_subnets
  project         = var.project
  environment     = var.environment
}

# ALB Module
resource "aws_lb" "app" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.vpc.alb_security_group_id]
  subnets            = module.vpc.public_subnet_ids

  tags = {
    Name = "${var.project}-${var.environment}-alb"
  }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.project}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "${var.project}-${var.environment}-tg"
  }
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ASG Module
module "asg" {
  source = "./modules/asg"

  project       = var.project
  environment   = var.environment
  instance_type = var.instance_type

  min_size         = 2
  max_size         = 2
  desired_capacity = 2

  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.vpc.app_security_group_id
  user_data_path    = "${path.module}/user-data/ec2-init.sh"
  target_group_arns = [aws_lb_target_group.app.arn]
}