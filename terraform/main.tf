resource "aws_security_group" "frontend_access" {

  name        = "${var.project_name}-${var.project_env}-frontend"
  description = "${var.project_name}-${var.project_env}-frontend"


  ingress {

    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {

    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {

    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name    = "${var.project_name}-${var.project_env}-frontend"
    Project = "${var.project_name}"
    Env     = "${var.project_env}"
  }
}



resource "aws_instance" "frontend" {

  ami                    = data.aws_ami.latest_ami.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.frontend_access.id]
  tags = {
    Name    = "${var.project_name}-${var.project_env}-frontend"
    Project = "${var.project_name}"
    Env     = "${var.project_env}"
  }
}


resource "aws_eip" "frontend" {
  instance = aws_instance.frontend.id
  domain   = "vpc"
}


resource "aws_route53_record" "frotned" {

  zone_id = data.aws_route53_zone.prod.zone_id
  name    = "${var.hostname}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.frontend.public_ip]
}


