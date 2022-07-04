locals {
  nginx_tags = merge({ Name : "nginx-server" }, var.tags, local.tags)
}

resource "aws_iam_role" "nginx" {
  name_prefix = "nginx-server-"

  tags = merge(var.tags, local.tags, {
    git_file = "nginx-server.tf"
    git_org  = "managedkaos"
    git_repo = "nginx-development-environment"
  })

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nginx" {
  role       = aws_iam_role.nginx.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nginx" {
  name_prefix = "nginx-server-"
  role        = aws_iam_role.nginx.name

  tags = merge(local.nginx_tags, {
    git_file = "nginx-server.tf"
    git_org  = "managedkaos"
    git_repo = "nginx-development-environment"
  })
}

resource "aws_security_group" "nginx" {
  name_prefix = "nginx-server-"
  description = "nginx"
  vpc_id      = var.vpc_id

  tags = merge(local.nginx_tags, {
    git_file = "nginx-server.tf"
    git_org  = "managedkaos"
    git_repo = "nginx-development-environment"
  })

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = coalesce("ami-0637e7dc7fcc9a2d9", data.aws_ami.ami["ubuntu"].id)
  instance_type               = "t3a.medium"
  associate_public_ip_address = true
  disable_api_termination     = false
  user_data                   = file("${path.module}/user_data/nginx_v2.txt")
  key_name                    = aws_key_pair.key["ubuntu"].key_name
  security_groups             = [aws_security_group.nginx.name]
  volume_tags                 = local.nginx_tags
  iam_instance_profile        = aws_iam_instance_profile.nginx.name

  tags = merge(local.nginx_tags, {
    git_file = "nginx-server.tf"
    git_org  = "managedkaos"
    git_repo = "nginx-development-environment"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "nginx" {
  vpc = true
  tags = merge(local.nginx_tags, {
    git_file = "nginx-server.tf"
    git_org  = "managedkaos"
    git_repo = "nginx-development-environment"
  })
}

resource "aws_eip_association" "nginx" {
  instance_id   = aws_instance.nginx.id
  allocation_id = aws_eip.nginx.id
}

output "nginx_public_dns" {
  value = aws_eip.nginx.public_dns
}

output "nginx_instance_id" {
  value = aws_instance.nginx.id
}
