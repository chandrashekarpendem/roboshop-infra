module "network_vpc" {
  source = "github.com/chandrashekarpendem/Terraform-module-vpc.git"

  for_each    = var.vpc
  env         = var.env
  cidr_block  = each.value.cidr_block
  public_cidr_block= each.value.public_cidr_block
  private_cidr_block= each.value.private_cidr_block

}