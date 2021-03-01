resource "aws_instance" "portchain_instance" {
  ami                    = "ami-0915bcb5fa77e4892" // Amazon Linux 2
  subnet_id              =  aws_subnet.portchain_subnet.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.portchain_instance_profile.id
  vpc_security_group_ids = [ aws_security_group.allow_http_https.id ]
  associate_public_ip_address = true
  key_name = "test"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = "true"
  }
  user_data = <<-EOT
  curl -L https://github.com/docker/compose/releases/download/1.28.5/docker-compose-Linux-x86_64 -o /tmp/docker-compose
  chmod +x /tmp/docker-compose
  EOT

  tags = {
    Name                   = "portchain"
  }

  lifecycle {
    ignore_changes         = ["ami", "user_data", "subnet_id", "key_name"]
  }
}