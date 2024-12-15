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

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = merge(local.common_tags, { Name="${var.env}_docdb_security_group" })
}