output "my_ip_public_public_EC2" {
  value = aws_instance.demo.public_ip  
}