data "aws_ssm_parameter" "rds_user" {
  name = "${var.env}.rds.user"
}
data "aws_ssm_parameter" "rds_pass" {
  name = "${var.env}.rds.pass"
}
data "aws_kms_key" "roboshop_key" {
  key_id = "alias/roboshop"
}