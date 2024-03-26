terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

# Create a Private ECR registry
resource "aws_ecr_repository" "my_repository" { 
  name         = "dockerize-web-ap"  # Replace with your desired ECR repository name
  scan_on_push = false 
}


data "aws_vpc" "default" {
  default = true
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
    
resource "aws_key_pair" "kp" {
  key_name   = "test-Key"       # Create a "wellness-Key" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh
}
    
resource "local_file" "tf-key" {
  content  = tls_private_key.pk.private_key_pem
  filename = "test-key-pair"
}

# Create EC2 instance where docker container will run
resource "aws_instance" "my_instance" {
  ami           = "ami-0c7fb0b886181be80"  # Replace with your desired AMI ID
  instance_type = "t2.micro"  # Replace with your desired instance type
  subnet_id     = data.aws_vpc.default.subnet_ids[0]
  key_name      = aws_key_pair.kp.key_name


  tags = {
    Name = "MyEC2Instance"
  }


  user_data = <<EOF
#!/bin/bash

sudo yum install docker -y
sudo systemctl enable docker --now

EOF
}  