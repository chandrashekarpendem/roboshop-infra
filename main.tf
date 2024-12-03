module "network_vpc" {
  source = "github.com/chandrashekarpendem/Terraform-module-vpc.git"

  for_each    = var.network_vpc
  cidr_block  = each.value.cidr_block

}