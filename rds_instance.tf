resource "random_password" "rds_master_password" {
  length  = 10
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_id" "prefix" {
  byte_length = 5
}

resource "aws_secretsmanager_secret" "db_secretmetadata" {
  name       = "db_secret-${random_id.prefix.hex}"
  kms_key_id = aws_kms_key.secretsmanager.arn
}

resource "aws_secretsmanager_secret_version" "db_secretvalue" {
  secret_id     = aws_secretsmanager_secret.db_secretmetadata.id
  secret_string = random_password.rds_master_password.result
}


resource "aws_db_subnet_group" "private_db_subnet_group" {
  name       = "private-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "Private DB Subnet Group"
  }
}



# RDS Database Instance
resource "aws_db_instance" "csye6225_instance" {
  identifier           = var.db_identifier
  engine               = var.db_engine
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  db_name              = var.db_name
  username             = var.db_username
  password             = aws_secretsmanager_secret_version.db_secretvalue.secret_string
  storage_encrypted    = true
  kms_key_id           = aws_kms_key.rds.arn
  parameter_group_name = aws_db_parameter_group.csye6225pg.name
  db_subnet_group_name = aws_db_subnet_group.private_db_subnet_group.name
  publicly_accessible  = false
  multi_az             = false
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "CSYE6225 RDS Instance"
  }
}

output "generated_mysql_password" {
  value     = random_password.rds_master_password.result
  sensitive = true
}
