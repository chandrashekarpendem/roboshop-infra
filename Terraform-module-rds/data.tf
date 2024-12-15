data "aws_ssm_parameter" "rds_user" {
  name = "${var.env}.rds_db.user"
}
data "aws_ssm_parameter" "rds_pass" {
  name = "${var.env}.rds_db.pass"
}
data "aws_kms_key" "roboshop_key" {
  key_id = "alias/roboshop"
}