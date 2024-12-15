locals {
  common_tags = {
    Environment   = var.env
    Project       = "RobotShop"
    Business_unit = "Ecommerce"
    Owner         = "Robot"
  }
  all_tags = [
    { key = "env" , value = var.env } ,
    { key = "project" , value = "roboshop1" },
    { key = "business_unit" , value = "ecommerce" },
    { key = "owner" , value = "ecommerce_robot" },
    { key = "Name" , value = "${var.env}-${var.component}" }
  ]
}