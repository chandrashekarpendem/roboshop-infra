resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name = "${var.env}-docdb_subnet_group"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {Name="${var.env}-docdb_subnet_group"})
}

resource "aws_security_group" "docdb_sg" {
  name        = "Name=${var.env}-docdb_security_group"
  description = "Name=${var.env}-docdb_security_group"
  vpc_id = var.vpc_id


  ingress {
    description      = "MONGODB"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr_docdb

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

tags = merge(local.common_tags, { Name="${var.env}-security_group" })
}
#
#resource "aws_docdb_cluster_instance" "cluster_instances" {
#  count              = 2
#  identifier         = "docdb-cluster-demo-${count.index}"
#  cluster_identifier = aws_docdb_cluster.default.id
#  instance_class     = "db.r5.large"
#}

resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier = "Name=${var.env}-docdb_cluster"
  engine = "docdb"
  engine_version = var.engine_version
  availability_zones = var.availability_zone
  master_username    = data.aws_ssm_parameter.docdb_user.value
  master_password    = data.aws_ssm_parameter.docdb_pass.value
  skip_final_snapshot = true
  db_subnet_group_name = aws_docdb_subnet_group.docdb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.docdb_sg.id]

  tags = merge(local.common_tags, { Name="${var.env}-docdb_cluster" })
}