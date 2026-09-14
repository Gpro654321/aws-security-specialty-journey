data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "week2-lab-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone[0]

  tags = {
    Name = "week2-lab-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone[0]

  tags = {
    Name = "week2-lab-private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  region = var.region

  tags = {
    Name = "week2-lab-internet-gateway"
  }

}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  region = var.region

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "week2-public-route-table"
  }

}

# this will be attached to the private subnet
# delibertely no route to Internet gateway, this table stays private only
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  region = var.region

  tags = {
    Name = "week2-private-route-table"
  }

}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # which AWS service should be allowed to assume this?
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ec2_ssm_role"
  }
}

# Attach AWS's managed policy for SSM 
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" # AmazonSSMManagedInstanceCore's ARN
}

# The instance profile — this is the actual object that is attached to an EC2 instance;
# a role by itself can't be attached directly
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2_ssm_profile"
  role = aws_iam_role.ec2_ssm_role.name
}


# minimal security group to allow the ec2 instances to communicate with the
# SSM to via HTTPS
resource "aws_security_group" "instances_sg" {
  name   = "week2-lab-ssm-instances"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "week2-lab-ssm-sg"
  }


}

resource "aws_instance" "public_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id # public subnet reference
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name
  vpc_security_group_ids = [aws_security_group.instances_sg.id] # your security group reference

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y amazon-ssm-agent
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent
              EOF


  tags = {
    Name = "public_instance"
  }
}

resource "aws_instance" "private_instance" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.private_subnet.id # private subnet reference
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  vpc_security_group_ids = [aws_security_group.instances_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y amazon-ssm-agent
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent
              EOF

  tags = {
    Name = "private_instance"
  }
}

