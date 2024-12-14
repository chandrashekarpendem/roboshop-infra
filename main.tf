module "network_vpc" {
  source = "github.com/chandrashekarpendem/Terraform-module-vpc.git"

  for_each           = var.vpc
  env                = var.env
  default_vpc_id     = var.default_vpc_id

  cidr_block         = each.value.cidr_block
  availability_zone  = each.value.availability_zone
  private_subnets    = each.value.private_subnets
  public_subnets     = each.value.public_subnets


}

module "docdb" {
  source = "./Terraform-module-docdb"
  env       = var.env

  for_each                = var.docdb
  number_of_instances     = each.value.number_of_instances
  instance_class          = each.value.instance_class
  subnet_ids              = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name,null ), "private_subnets_ids", null), each.value.subnets_name, null),"subnets_ids", null)
  vpc_id                  = lookup(lookup(module.network_vpc,each.value.vpc_name,null ), "vpc_id",null)

#  allow_cidr_docdb = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null ), "private_subnets" , null), "app",null), "cidr_block", null)
  allow_cidr_docdb        = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name, null ), "private_subnets_ids", null), "app",null), "app_cidr_block" ,null)

  engine_version           = each.value.engine_version

}

module "rds" {
  source = "./Terraform-module-rds"
  env                     = var.env
  for_each                = var.rds
  number_of_instances     = each.value.number_of_instances
  instance_class          = each.value.instance_class
  engine_version          = each.value.engine_version
  engine                  = each.value.engine

  vpc_id                  = lookup(lookup(module.network_vpc,each.value.vpc_name,null ), "vpc_id",null)
  allow_cidr_rds          = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name, null ), "private_subnets_ids", null), "app",null), "app_cidr_block" ,null)
  subnet_ids              = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name,null ), "private_subnets_ids", null), each.value.subnets_name, null),"subnets_ids", null)
}

module "elastic_cache_redis" {
  source = "./Terraform-module-elasticache"
  env                     = var.env
  for_each                = var.elastic_cache_redis
  node_type               = each.value.node_type
  replicas_per_node_group = each.value.replicas_per_node_group
  num_node_groups         = each.value.num_node_groups
  vpc_id                  = lookup(lookup(module.network_vpc,each.value.vpc_name,null ), "vpc_id",null)
  allow_cidr_rds          = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name, null ), "private_subnets_ids", null), "app",null), "app_cidr_block" ,null)
  subnet_ids              = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name,null ), "private_subnets_ids", null), each.value.subnets_name, null),"subnets_ids", null)
}

module "alb" {
  source = "./Terraform-module-alb"
  env                     = var.env
  for_each                = var.alb

  subnets_name            = each.value.subnets_name

  vpc_id                  = lookup(lookup(module.network_vpc,each.value.vpc_name,null ), "vpc_id",null)
  allow_cidr_rds          = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name, null ), "private_subnets_ids", null), "app",null), "app_cidr_block" ,null)
  subnet_ids              = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name,null ), each.value.subnets_type, null), each.value.subnets_name, null),"subnets_ids", null)
}
output "vpc" {
  value = module.network_vpc
}


