output "alb_dns_name" {
  value = aws_alb.ALB.dns_name
}

output "listeners" {
  value = try(aws_lb_listener.listeners.*.arn[0], null)
}