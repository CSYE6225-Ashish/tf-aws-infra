resource "aws_launch_template" "app_server_launch_template" {
  # Launch template name and description

  name_prefix = "app-server-template"

  # Application and OS Images (Amazon Machine Image)
  image_id      = var.custom_ami
  instance_type = "t2.micro"

  # Attaching instance profile to the instance that would be launched
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  # Attaching security group to instance
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.webapp_application_sg.id]
  }

  #  Attach EBS volume to the device
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 8
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2.arn
    }
  }

  # User data that would be used while launching instance
  user_data = base64encode(<<-EOF
    #!/bin/bash
    
    SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.db_secretmetadata.arn} --query SecretString --output text)

    # Existing environment variables from AWS DB Instance
    echo "DB_HOST=\"${split(":", aws_db_instance.csye6225_instance.endpoint)[0]}\"" > /opt/csye6225/.env
    echo "DB_USERNAME=\"${aws_db_instance.csye6225_instance.username}\"" >> /opt/csye6225/.env
    echo "DB_PASSWORD=\"$SECRET_VALUE\"" >> /opt/csye6225/.env
    echo "DB_NAME=\"${aws_db_instance.csye6225_instance.db_name}\"" >> /opt/csye6225/.env
    echo "S3_BUCKET=\"${aws_s3_bucket.private_bucket.id}\"" >> /opt/csye6225/.env
    echo "AWS_REGION=\"${var.region}\"" >> /opt/csye6225/.env
    echo "ENV=\"${var.ENV}\"" >> /opt/csye6225/.env
    echo "PORT=\"${var.PORT}\"" >> /opt/csye6225/.env
    
    sudo chown csye6225:csye6225 /opt/csye6225/.env

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

  EOF
  )

  disable_api_termination = false

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "App Server"
    }
  }
}
