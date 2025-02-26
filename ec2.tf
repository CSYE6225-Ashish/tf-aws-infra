resource "aws_instance" "app_server" {
  ami                    = var.custom_ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  disable_api_termination = false

  tags = { Name = "App Server" }
}
