
provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "test_vpc" {
 cidr_block = "10.0.0.0/16"
 tags = {
   Name = "test_vpc"
 } 
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-3a"
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-3b"
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "private_subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}
  
resource "aws_route_table_association" "public_asn" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_instance" "terraform_server" {
  ami           = "ami-0c20d3687f779643a"
  instance_type = "t2.micro"
  key_name      = "Chessylinuxserver"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  

  user_data = <<-EOF
             #!/bin/bash
             sudo yum update -y
             sudo yum install -y httpd
             sudo systemctl start httpd
             sudo systemctl enable httpd
             echo "<h1>Hello, Terraform!</h1>" | sudo tee /var/www/html/index.html
            EOF

  tags = {
    Name = "terraform_server"
  }
}

resource "aws_security_group" "web_sg"  {
  vpc_id      = aws_vpc.test_vpc.id
  name        = "web-server-sg"
  description = "Allow HTTP traffic"
  
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
}

resource "aws_security_group" "lb_sg"  {
  vpc_id      = aws_vpc.test_vpc.id
  name        = "lb-sg"
  description = "Allow HTTP traffic"
  
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
    }
  }  

resource "aws_launch_template" "lt" {
  image_id = "ami-0c20d3687f779643a"
  instance_type = "t2.micro"
  key_name = "Chessylinuxserver"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data = base64encode(<<-EOF
             #!/bin/bash
             sudo yum update -y
             sudo yum install -y httpd
             sudo systemctl start httpd
             sudo systemctl enable httpd
             echo "<h1>Hello, Terraform!</h1>" | sudo tee /var/www/html/index.html
            EOF
            )
  network_interfaces {
    associate_public_ip_address = true 
    device_index                = 0
  }          
}  

resource "aws_autoscaling_group" "asg" {
  max_size = 1
  min_size = 1
  desired_capacity = 1
  launch_template {
    id = aws_launch_template.lt.id
  }
  target_group_arns = [aws_lb_target_group.tg.arn] 
  vpc_zone_identifier  = [aws_subnet.public_subnet.id]
}

resource "aws_lb" "terraform_alb" {
  name               = "terraform-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "terraform-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.terraform_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "public_ip" {
value = "${aws_instance.terraform_server.public_ip}"
}