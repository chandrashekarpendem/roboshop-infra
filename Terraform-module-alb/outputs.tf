output "alb_dns_name" {
  value = aws_alb.ALB.dns_name
}
output "alb_arn" {
  value = aws_alb.ALB.arn
}
output "listeners" {
  value = try(aws_lb_listener.listeners.*.arn[0], null)
}