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
  number_of_instance     = each.value.number_of_instance
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
  engine_version          = each.value.engine_version
  num_cache_nodes         = each.value.num_cache_nodes
  vpc_id                  = lookup(lookup(module.network_vpc,each.value.vpc_name,null ), "vpc_id",null)
  allow_cidr_rds          = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name, null ), "private_subnets_ids", null), "app",null), "app_cidr_block" ,null)
  subnet_ids              = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name,null ), "private_subnets_ids", null), each.value.subnets_name, null),"subnets_ids", null)
}

module "alb" {
  source = "./Terraform-module-alb"
  env                     = var.env
  for_each                = var.alb

  subnets_name            = each.value.subnets_name
  internal                = each.value.internal
  vpc_id                  = lookup(lookup(module.network_vpc,each.value.vpc_name,null ), "vpc_id",null)
  allow_cidr_alb          =  each.value.internal ? concat(lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null ), "private_subnets" , null), "web",null), "cidr_block", null), lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null ), "private_subnets" , null), "app",null), "cidr_block", null)): [ "0.0.0.0/0" ]
  subnet_ids              = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name,null ), each.value.subnets_type, null), each.value.subnets_name, null),"subnets_ids", null)
}

module "apps" {
  source = "./Terraform-module-app"
  env                     = var.env
  for_each                = var.apps
  allow_bastion_cidr      = var.allow_bastion_cidr
  monitor_cidr            = var.monitor_cidr
  depends_on = [module.docdb, module.rds, module.elastic_cache_redis, module.rabbitmq]

  component               = each.value.component
  app_port                = each.value.app_port
  listener_priority       = each.value.listener_priority
  desired_capacity        = each.value.desired_capacity
  max_size                = each.value.max_size
  min_size                = each.value.min_size
  instances_type          = each.value.instances_type
  alb_dns_name            = lookup(lookup(module.alb, each.value.alb, null),"alb_dns_name",null)
  listeners               = lookup(lookup(module.alb, each.value.alb,null ),"listeners", null)
  alb_arn                 = lookup(lookup(module.alb, each.value.alb,null ),"alb_arn", null)
  vpc_id                  = lookup(lookup(module.network_vpc,each.value.vpc_name,null ), "vpc_id",null)
  allow_cidr_apps         = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null ), each.value.allow_cidr_subnets_type , null), each.value.allow_cidr_subnets_name,null), "cidr_block", null)
  subnet_ids              = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name,null ), each.value.subnets_type, null), each.value.subnets_name, null),"subnets_ids", null)
}

module "rabbitmq" {
  source = "./Terraform-module-rabbittmq"
  env                     = var.env
  for_each                = var.rabbitmq
  allow_bastion_cidr      = var.allow_bastion_cidr
  component               = each.value.component


  vpc_id                  = lookup(lookup(module.network_vpc,each.value.vpc_name,null ), "vpc_id",null)
  allow_cidr_apps          = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name, null ), "private_subnets_ids", null), "app",null), "app_cidr_block" ,null)
  subnet_ids              = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name,null ), "private_subnets_ids", null), each.value.subnets_name, null),"subnets_ids", null)
}
output "vpc" {
  value = module.network_vpc
}

output "rabbitmq" {
  value = module.rabbitmq
}
output "alb" {
  value = module.alb
}
output "apps" {
  value = module.apps
}
output "elastic_cache_redis" {
  value = module.elastic_cache_redis
}