provider "aws" {
  region     = "ap-southeast-1"  
} 

# 
#    setting resources for crate aws key pair and download it in local directory
# 

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

# 
#    Create local for map port in ec2 security group
# 

locals {
  ingress_rule = [{
    port = 80
    description = "Ingress rule for port 80"
  },
  {
    port = 22
    description = "Ingress rule for port 22"
  },
  {
    port = 433
    description = "Ingress rule for port 433"
  },
  {
    port = 3389
    description = "Ingress rule for port 3389"
  }
  
  
  ]
}


# 
#    Create VPC
# 


resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "demo vpc"
  }
}

# 
#    Create Subnet
# 

resource "aws_subnet" "demo_subnet" {
  vpc_id     = "${aws_vpc.demo_vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "demo Subnet"
  }
}

# 
#    Create EC2 Instance
# 

resource "aws_instance" "demo" {
    
    ami = var.ami_linux
    instance_type = var.instance_type
    key_name = "aws-demo-key"
    
    vpc_security_group_ids = [aws_security_group.demo_sg.id]    
    subnet_id = aws_subnet.demo_subnet.id 
    //count = var.instance_count
    associate_public_ip_address = var.enable_public

    tags = {
      Name = "private EC2"
    } 
}

# 
#    Create security group
# 

resource "aws_security_group" "demo_sg" {
   name        = "allow_tls"
   description = "Allow TLS inbound traffic and all outbound traffic"
   vpc_id      = aws_vpc.demo_vpc.id

   dynamic "ingress" {
      for_each = local.ingress_rule

      content {
        description = ingress.value.description
        from_port   = ingress.value.port
        to_port     = ingress.value.port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
   }

   tags = {
     Name = " Public Security Group"
   }
}
