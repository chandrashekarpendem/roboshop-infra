resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name = "${var.env}-docdb_subnet_group"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {Name="${var.env}-docdb_subnet_group"})
}

resource "aws_security_group" "docdb_sg" {
  name        = "${var.env}-docdb_security_group"
  description = "${var.env}-docdb_security_group"
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

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.number_of_instances
  identifier         = "${var.env}-docdb-cluster-${count.index+1}"
  cluster_identifier = aws_docdb_cluster.docdb_cluster.id
  instance_class     = var.instance_class

  tags = merge(local.common_tags, {Name="${var.env}-docdb_cluster_instance"})
}

resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier = "${var.env}-docdb-cluster"
  engine = "docdb"
  engine_version = var.engine_version
  master_username    = data.aws_ssm_parameter.docdb_user.value
  master_password    = data.aws_ssm_parameter.docdb_pass.value
  skip_final_snapshot = true
  db_subnet_group_name = aws_docdb_subnet_group.docdb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.docdb_sg.id]

  tags = merge(local.common_tags, { Name="${var.env}-docdb_cluster" })
}