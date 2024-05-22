provider "aws" {
  region     = "ap-southeast-1"  
} 

resource "aws_key_pair" "project1_key" {
  key_name   = "aws-demo-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "aws-demo-key.pem"
}