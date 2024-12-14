
data "aws_kms_key" "roboshop_key" {
  key_id = "alias/roboshop"
}