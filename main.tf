terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "us-east-2"
  profile = "ec2_user"
}

resource "aws_key_pair" "brian" {
  key_name = "brian_drupal_dev"
  public_key = file("key_pairs/brian.pub")
}

resource "aws_security_group" "drupal_dev_group" {
  name = "drupal_dev_group"
  description = "Allow HTTP and SSH on default ports"

  ingress {
    description = "Allow HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Terraform removes this by default.
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "drupal_server" {
  key_name = aws_key_pair.brian.key_name
  ami           = "ami-00399ec92321828f5"
  instance_type = "t2.micro"

  vpc_security_group_ids = [ "${aws_security_group.drupal_dev_group.id}" ]

  tags = {
    Name = "DrupalDevInstance"
  }
}

output "aws_instance_public_dns" {
  value = aws_instance.drupal_server.public_dns
}

output "connection_string" {
  value = "ssh -i private_key ubuntu@${aws_instance.drupal_server.public_dns}"
}