resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "${var.env}-rds_subnet_group"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {Name="${var.env}-rds-subnet-group"})
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.env}-rds_security_group"
  description = "${var.env}-rds_security_group"
  vpc_id = var.vpc_id


  ingress {
    description      = "RDS"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr_rds

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = merge(local.common_tags, { Name="${var.env}-rds-security_group" })
}

#resource "aws_rds_cluster_instance" "rds-cluster_instances" {
#  count              = var.number_of_instance
#  identifier         = "${var.env}-rds-cluster-${count.index+1}"
#  cluster_identifier = aws_rds_cluster.rds-cluster.id
#
#}

resource "aws_rds_cluster" "rds-cluster" {
  cluster_identifier = "${var.env}-rds-cluster"

  engine             = var.engine
  engine_version     = var.engine_version
  db_cluster_instance_class = var.instance_class

  master_username         = data.aws_ssm_parameter.rds_user.value
  master_password         = data.aws_ssm_parameter.rds_pass.value
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  storage_encrypted       = true
  kms_key_id              = data.aws_kms_key.roboshop_key.arn

  tags = merge(local.common_tags, {Name="${var.env}-rds-cluster"})
}