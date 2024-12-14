resource "aws_security_group" "alb_sg" {
  name        = "${var.env}-${var.subnets_name}-ALB-security_group"
  description = "${var.env}-${var.subnets_name}-ALB-security_group"
  vpc_id = var.vpc_id


  ingress {
    description      = "HTTP-ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr_rds

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = merge(local.common_tags, { Name="${var.env}-alb-security_group" })
}