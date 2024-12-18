data "aws_ami" "centos8" {
  most_recent = true
  owners = [225989332181]
}
data "aws_kms_key" "roboshop_key" {
  key_id = "alias/roboshop"
}