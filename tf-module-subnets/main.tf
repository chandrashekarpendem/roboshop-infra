resource "aws_subnet" "subnet" {
  count  = length(var.cidr_block)
  availability_zone = var.availability_zone[count.index]
  vpc_id = var.vpc_id
  cidr_block = var.cidr_block[count.index]
  tags       = merge(local.common_tags,{ Name= "${var.env}-subnet_${count.index + 1}" })
}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id =
#  }

  route {
    cidr_block                = data.aws_vpc.default_vpc_info.cidr_block
    vpc_peering_connection_id = var.vpc_peering_connection_id
  }
  tags       = merge(local.common_tags,{ Name= "${var.env}-route_table" })

 }

resource "aws_route_table_association" "private_route_table_association_to_private_subnets" {
  count = length(aws_subnet.subnet) # here we are iterating with count i.e you plz run times of private_subnet has
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.subnet.*.id[count.index]

}