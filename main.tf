terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  },
    {
      cidr_blocks      = [ "0.0.0.0/0" ]
      description      = ""
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      from_port        = 3000
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 3000
    }
  ]

}

resource "aws_instance" "app_server" {
  ami           = "ami-087da76081e7685da" 
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.main.id]  
  key_name      = "aws-ssh-key"

   depends_on = [aws_key_pair.aws_key_for_ec2]

    connection {
        type        = "ssh"
        user        = "admin"  
        private_key = file("/Users/marouane/.ssh/aws-ssh-key")  
        host        = aws_instance.app_server.public_ip     
    }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y nodejs npm",
      "sudo npm install pm2 -g",
      "sudo npm install -g n",
      "sudo n stable",
      "git clone https://github.com/marouaneTalbi/imple_node_api.git",
      "cd imple_node_api",
      "npm install",
      "sudo pm2 start app.js"
    ]
  }

  tags = {
    Name = "ec2-esgi-3"
  }
}

resource "aws_key_pair" "aws_key_for_ec2" {
  key_name   = "aws-ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYuYg3BOrPpar+KDI4V3uIb0VK+x5QHS+aI4OO1fwVU9Pr3OlWJAZeC0yjSth17TR4iXuiZhpTNu73eBTt1rObS+nTfH2aTQTszViW92Kn0uYO9e+nUUB1I/dAljqyve7oWeRYYOztg7WBoZtRSXZFTbAS1wEfbtwoVyhRCwFluwaj/NOC64aoBJe4OmIsoTYgF3wpEg3sKir0rmcXvVfqLSxOVCGykuVjeb0dxc2cYIxncFbW2s+4UPG5Z8R9h/FEftrifN600I6vdLS8UwJxCQyRKpeJBWz/L88LKjwMECGA3av3AO5lGu8U7Int/lPizIZrmtJQo2/Rxv2E7+t3 marouane@macbook-air.home"
}