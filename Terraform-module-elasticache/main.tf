resource "aws_elasticache_subnet_group" "elastic_cache_subnet_group" {
  name = "${var.env}-elastic-cache-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {Name="${var.env}-elastic_cache_subnet_group"})
}

resource "aws_security_group" "elastic_cache_sg" {
  name        = "${var.env}-elastic_cache_security_group"
  description = "${var.env}-elastic_cache_security_group"
  vpc_id = var.vpc_id


  ingress {
    description      = "elastic_cache"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr_rds

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = merge(local.common_tags, { Name="${var.env}-elastic_cache-security_group" })
}
#
#resource "aws_elasticache_replication_group" "elastic_cache_replication_group" {
#  replication_group_id = "${var.env}-elastic-cache-replication-group"
#  replication_group_description = "${var.env}-elastic-cache-replication-group"
#  node_type = var.node_type
#  port = 6379
#  subnet_group_name = aws_elasticache_subnet_group.elastic_cache_subnet_group.name
#  security_group_ids = [aws_security_group.elastic_cache_sg.id]
#  automatic_failover_enabled = true
#  num_node_groups = var.num_node_groups
#  replicas_per_node_group = var.replicas_per_node_group
#
#  tags = merge(local.common_tags, {Name="${var.env}-elastic_cache_replication_group"})
#}
resource "aws_elasticache_cluster" "elastic_cache" {
  cluster_id           = "${var.env}-elasti-cache-cluster"
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  engine_version       = var.engine_version
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.elastic_cache_subnet_group.name
  security_group_ids   = [aws_security_group.elastic_cache_sg.id]
  tags                 = merge (local.common_tags, { Name = "${var.env}-elasticache_subnet_group" } )

}