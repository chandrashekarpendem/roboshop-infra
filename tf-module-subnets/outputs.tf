output "all_subnets_ids" {
  value = aws_subnet.subnet.*.id
}