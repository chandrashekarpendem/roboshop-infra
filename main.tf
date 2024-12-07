module "network_vpc" {
  source = "github.com/chandrashekarpendem/Terraform-module-vpc.git"

  for_each           = var.vpc
  env                = var.env
  default_vpc_id     = var.default_vpc_id
  cidr_block         = each.value.cidr_block

}

module "subnets" {
  source              = "./tf-module-subnets"
  env                 = var.env
  default_vpc_id      = var.default_vpc_id


  for_each   = var.subnets
  cidr_block = each.value.cidr_block
  name       = each.value.name
  gateway_id = module.network_vpc
  availability_zone = each.value.availability_zone
  vpc_id = lookup(lookup(module.network_vpc,each.value.vpc_name,null), "vpc_id", null)
  vpc_peering_connection_id = lookup(lookup(module.network_vpc,each.value.vpc_name,null), "vpc_peering_connection_id", null)


}

output "vpc" {
  value = module.network_vpc
}


