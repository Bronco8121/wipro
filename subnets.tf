resource "aws_subnet" "pub_subnet" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.pub_sub_cidr_block)
  cidr_block        = element(var.pub_sub_cidr_block, count.index)
  availability_zone = element(var.az, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = element(var.pub_subnet_tags, count.index)
  }
}


resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.pri_sub_cidr_block)
  cidr_block        = element(var.pri_sub_cidr_block, count.index)
  availability_zone = element(var.az, count.index)
  tags = {
    Name = element(var.pri_subnet_tags, count.index)
  }
}