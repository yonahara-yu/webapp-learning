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
set -eux

yum update -y
yum install -y nginx git

# Node.js 20 をインストール
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs

# nginxの設定ファイル書き込み
cat <<'NGINXCONF' > /etc/nginx/conf.d/default.conf
${file("${path.module}/files/nginx.conf")}
NGINXCONF

# nginx 起動
systemctl enable nginx
systemctl start nginx

# GitHub から clone
cd /tmp
git clone https://github.com/yonahara-yu/webapp-learning.git
cd webapp-learning/frontend

# distをビルド
npm install
npm run build

# nginx 配信用ディレクトリにコピー
rm -rf /usr/share/nginx/html/*
cp -r dist/* /usr/share/nginx/html/

systemctl reload nginx
EOF

    tags = {
        Name = "learning-web"
    }
}
