data "aws_ssm_parameter" "docdb_user" {
  name = "${var.env}.docdb.user"
}
data "aws_ssm_parameter" "docdb_pass" {
  name = "${var.env}.docdb.pass"
}