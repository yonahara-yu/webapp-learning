provider "aws" {
    region = "ap-northeast-1"
}

resource "aws_security_group" "web" {
    name        = "web-sg"
    description = "Security group for web app"

    tags = {
        Name = "web-sg"
    }

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "terraform_key" {
    key_name   = "terraform-ec2-key"
    public_key = file("~/.ssh/terraform-ec2.pub")
}


data "aws_ami" "amazon_linux" {
    most_recent = true

    filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
    }

    filter {
    name   = "architecture"
    values = ["x86_64"]
    }

    owners = ["amazon"]
}


resource "aws_instance" "web" {
    ami           = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"  #無料枠

    key_name = aws_key_pair.terraform_key.key_name

    vpc_security_group_ids = [
        aws_security_group.web.id
    ]

    ##ec2起動時に一度だけ実行
    user_data = <<EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx
    EOF

    tags = {
        Name = "learning-web"
    }
}
