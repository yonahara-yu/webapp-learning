provider "aws" {
    region = "ap-northeast-1"
}

#セキュリティグループの設定
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

#キーペアの設定
resource "aws_key_pair" "terraform_key" {
    key_name   = "terraform-ec2-key"
    public_key = file("~/.ssh/terraform-ec2.pub")
}


#マシンイメージの設定
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


##EC2インスタンスの設定
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

#EIPの作成
resource "aws_eip" "web" {
    domain = "vpc"

    tags = {
    Name = "learning-web-eip"
    }
}

#EIPをEC2に紐付け
resource "aws_eip_association" "web" {
    instance_id   = aws_instance.web.id
    allocation_id = aws_eip.web.id
}

#ホストゾーンをterraform管理するとNSレコードがドメイン指定のNSと合致しなくなるので管理対象から外す
#Route53既存ホストゾーンを参照
data "aws_route53_zone" "main" {
    name         = "web-learning.click."
    private_zone = false
}

#Aレコード作成
resource "aws_route53_record" "web" {
    zone_id = data.aws_route53_zone.main.zone_id
    name    = "web-learning.click"
    type    = "A"
    ttl     = 60
    records = [aws_eip.web.public_ip]
}

