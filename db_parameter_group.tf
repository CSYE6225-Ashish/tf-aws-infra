resource "aws_db_parameter_group" "csye6225pg" {
  name   = "rds-pg"
  family = "mysql8.0"
}