data "aws_ssm_parameter" "docdb_user" {
  name = "${var.env}.doc_db.user"
}
data "aws_ssm_parameter" "docdb_pass" {
  name = "${var.env}.doc_db.pass"
}