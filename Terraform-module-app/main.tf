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

  tags = merge(local.common_tags, { Name="${var.env}_app_security_group" })
}

resource "aws_launch_template" "app_launch_template" {
  name_prefix = "${var.env}-app-launch-template"
  image_id = data.aws_ami.roboshop_ami.id
  instance_type = var.instances_type


}

resource "aws_autoscaling_group" "auto_scaling_group" {
  name                      = "${var.env}-${var.component}-autoscaling-group"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  force_delete              = true
  vpc_zone_identifier       = var.subnet_ids
#  target_group_arns = [aws_lb_target_group.target_group.arn]

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