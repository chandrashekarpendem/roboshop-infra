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

  for_each = var.docdb
  subnet_ids = lookup(lookup(lookup(lookup(module.network_vpc, each.value.vpc_name,null ), "private_subnets_ids", null), each.value.subnets_name, null),"subnets_ids", null)
  vpc_id = module.network_vpc.vpc_id


}

output "vpc" {
  value = module.network_vpc
}


