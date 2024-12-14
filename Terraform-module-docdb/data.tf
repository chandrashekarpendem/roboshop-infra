data "aws_ssm_parameter" "docdb_user" {
  name = "${var.env}.doc_db.user"
}
data "aws_ssm_parameter" "docdb_pass" {
  name = "${var.env}.doc_db.pass"
}
data "aws_kms_key" "roboshop_key" {
  key_id = "alias/roboshop"
}