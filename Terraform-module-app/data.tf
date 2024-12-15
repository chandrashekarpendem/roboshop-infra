data "aws_ami" "roboshop_ami" {
  most_recent = true
  owners = [225989332181]
}
data "aws_kms_key" "roboshop_key" {
  key_id = "alias/roboshop"
}