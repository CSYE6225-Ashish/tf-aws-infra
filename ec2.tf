resource "aws_instance" "app_server" {
  ami                    = var.custom_ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = <<-EOF
    #!/bin/bash

    # Existing environment variables from AWS DB Instance
    echo "DB_HOST=\"${split(":", aws_db_instance.csye6225_instance.endpoint)[0]}\"" > /opt/csye6225/.env
    echo "DB_USERNAME=\"${aws_db_instance.csye6225_instance.username}\"" >> /opt/csye6225/.env
    echo "DB_PASSWORD=\"${var.db_password}\"" >> /opt/csye6225/.env
    echo "DB_NAME=\"${aws_db_instance.csye6225_instance.db_name}\"" >> /opt/csye6225/.env
    echo "S3_BUCKET=\"${aws_s3_bucket.private_bucket.id}\"" >> /opt/csye6225/.env
    echo "AWS_REGION=\"${var.region}\"" >> /opt/csye6225/.env
    echo "ENV=\"${var.ENV}\"" >> /opt/csye6225/.env
    echo "PORT=\"${var.PORT}\"" >> /opt/csye6225/.env
    
    sudo chown csye6225:csye6225 /opt/csye6225/.env

  EOF




  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  disable_api_termination = false

  tags = { Name = "App Server" }
}
