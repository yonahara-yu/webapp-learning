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
    user_data  = templatefile("${path.module}/files/user_data.sh", {
    nginx_conf = file("${path.module}/files/nginx.conf")})

    tags = {
        Name = "learning-web"
    }
}