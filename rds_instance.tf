resource "random_password" "rds_master_password" {
  length  = 10
  special = true
  upper   = true
  lower   = true
  numeric = true
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
  password             = random_password.rds_master_password.result
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

