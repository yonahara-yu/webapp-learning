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