resource "aws_iam_role" "aws_app_instance_role" {
  name = "${var.env}-${var.component}-role"


  assume_role_policy = jsonencode({
    Version          = "2012-10-17"
    Statement        = [
      {
        Action       = "sts:AssumeRole"
        Effect       = "Allow"
        Sid          = ""
        Principal    = {
          Service    = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge (local.common_tags, { Name = "${var.env}-${var.component}-role" } )

}

resource "aws_iam_policy" "aws_parameter_policy" {
  name        = "${var.env}-${var.component}-parameter_store_role"
  path        = "/"
  description = "${var.env}-${var.component}-parameter_store_role"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource" : [
          "arn:aws:ssm:us-east-1:225989332181:parameter/${var.env}.${var.component}*",
          "arn:aws:ssm:us-east-1:225989332181:parameter/nexus*",
          "arn:aws:ssm:us-east-1:225989332181:parameter/${var.env}.doc*",
          "arn:aws:ssm:us-east-1:225989332181:parameter/${var.env}.elastic**",
          "arn:aws:ssm:us-east-1:225989332181:parameter/${var.env}.rds*",
          "arn:aws:ssm:us-east-1:225989332181:parameter/${var.env}.rabbitmq*",
          "arn:aws:ssm:us-east-1:225989332181:parameter/grafana*",
          "arn:aws:ssm:us-east-1:225989332181:parameter/${var.env}-SSH*"


        ]
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": "ssm:DescribeParameters",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "aws_app_instance_profile" {
 role = aws_iam_role.aws_app_instance_role.name
  name = "${var.env}-${var.component}-role"
}

resource "aws_iam_policy_attachment" "aws_policy_attachment_to_role" {
  name = "${var.env}-${var.component}-policy-attachment-to-role"
 roles = [aws_iam_role.aws_app_instance_role.name]
  policy_arn = aws_iam_policy.aws_parameter_policy.arn
}

resource "aws_security_group" "app_sg" {
  name        = "${var.env}-${var.component}_security_group"
  description = "${var.env}-${var.component}_security_group"
  vpc_id = var.vpc_id


  ingress {
    description      = "HTTP"
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr_apps

  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.allow_bastion_cidr

  }

  ingress {
    description      = "prometheus"
    from_port        = 9100
    to_port          = 9100
    protocol         = "tcp"
    cidr_blocks      = var.monitor_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = merge(local.common_tags, { Name="${var.env}_${var.component}_security_group" })
}

resource "aws_launch_template" "app_launch_template" {
  name_prefix = "${var.env}-app-${var.component}-launch-template"
  image_id = data.aws_ami.ami_id_robo.id
  instance_type = var.instances_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data = base64encode(templatefile("${path.module}/user_data.sh",{ component= var.component, env= var.env }))

  iam_instance_profile {
    arn = aws_iam_instance_profile.aws_app_instance_profile.arn
  }

  instance_market_options {
    market_type = "spot"
  }

}

resource "aws_autoscaling_group" "auto_scaling_group" {
  name                      = "${var.env}-${var.component}-autoscaling-group"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  force_delete              = true
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns = [aws_lb_target_group.target_group.arn]

  launch_template {
    id = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each              = local.all_tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = true
    }
  }

}
resource "aws_autoscaling_policy" "cpu-tracking-policy" {
  name        = "whenCPULoadIncrease"
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 30.0
  }
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.name
}
resource "aws_route53_record" "alb_DNS_record" {
  zone_id = "Z07864401KOK0U81PO524"
  name    = "${var.component}-${var.env}.chandrap.shop"
  type    = "CNAME"
  ttl     = 30
  records = [var.alb_dns_name]
}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.component}-${var.env}"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 5
    path = "/health"
    protocol = "HTTP"
    timeout = 2

  }
  deregistration_delay = "10"
}

//below listener rule for backend components
resource "aws_lb_listener_rule" "backend_listener_rule" {
  count = var.listener_priority != 0 ? 1 : 0
  listener_arn = var.listeners
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  condition {
    host_header {
      values = ["${var.component}-${var.env}.chandrap.shop"]
    }
  }
}

//frontend_app_listener
resource "aws_lb_listener" "frontend_app_listener" {
  count = var.listener_priority == 0 ? 1 : 0
  load_balancer_arn = var.alb_arn
  port              = "80"
  protocol          = "HTTP"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = "arn:aws:acm:us-east-1:195381906265:certificate/b5ff1caa-1d2a-4922-8567-cea866b137bc"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn

  }
}

resource "aws_lb_listener" "frontend_http_redirect" {
  count = var.listener_priority == 0 ? 1 : 0
  load_balancer_arn = var.alb_arn
  port              = "80"
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