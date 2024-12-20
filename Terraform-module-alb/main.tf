resource "aws_security_group" "alb_sg" {
  name        = "${var.env}-${var.subnets_name}-ALB-security_group"
  description = "${var.env}-${var.subnets_name}-ALB-security_group"
  vpc_id = var.vpc_id


  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr_alb

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = merge(local.common_tags, { Name="${var.env}-alb-${var.subnets_name}-security_group" })
}

resource "aws_alb" "ALB" {
  name = "${var.env}-alb-${var.subnets_name}"
  internal = var.internal
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = var.subnet_ids

  tags = merge(local.common_tags, {NAME="${var.env}-alb-${var.subnets_name}"})
}

//below listener  for backend components and frontend_listener_creating in app module
resource "aws_lb_listener" "listeners" {
  count = var.internal ? 1 : 0
  load_balancer_arn = aws_alb.ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "NO_RULE"
      status_code  = "503"
    }
  }
}