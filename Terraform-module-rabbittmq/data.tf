data "aws_ami" "centos8" {
  most_recent = true
  name_regex = "Chandra"
  owners = [225989332181]
}
data "aws_kms_key" "roboshop_key" {
  key_id = "alias/roboshop"
}