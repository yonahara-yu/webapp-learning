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