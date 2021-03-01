output "portchain_instance_public_ip" {
  value = aws_instance.portchain_instance.public_ip
}

output "portchain_instance_id" {
  value = aws_instance.portchain_instance.id
}