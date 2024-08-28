provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main_igw"
  }
}

resource "aws_route_table" "main_route_table" {
  count = 2 
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = element(var.pub_subnet_tags, count.index)
  }
}

resource "aws_route_table_association" "pub_subnet" {
  count = length(var.pub_sub_cidr_block)
  subnet_id      = element(aws_subnet.pub_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.main_route_table.*.id, count.index)
}


resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  ingress {
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

  tags = {
    Name = "sg"
  }
}

resource "aws_lb" "main" {
  name               = "main" 
  subnets = [for subnet in aws_subnet.pub_subnet : subnet.id]
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  

  enable_deletion_protection = false

  tags = {
    Name = "main-alb"
  }
}
resource "aws_lb_target_group" "mwipro" {
  name     = "mwipro-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}
resource "aws_lb_listener" "albwipro" {
    default_action {
        target_group_arn = aws_lb_target_group.mwipro.arn
        type = "forward"
    }
    load_balancer_arn = aws_lb.main.arn
    port              = 80
}

resource "aws_autoscaling_group" "asgwipro" {
  capacity_rebalance  = true
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = [for subnet in aws_subnet.pub_subnet : subnet.id]
  target_group_arns = [aws_lb_target_group.mwipro.arn]


  launch_template {
    id = aws_launch_template.wipro.id
    version = "$Latest"
    }
    
}




 
 