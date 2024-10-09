
# task_2

data "aws_ami" "al2023-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.5.*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_vpc" "primary" {
  cidr_block = var.primary_cidr_block
}

resource "aws_subnet" "public_a_az" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b_az" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_a_az" {
  vpc_id            = aws_vpc.primary.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_b_az" {
  vpc_id            = aws_vpc.primary.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.primary.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.primary.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }
}

# Without NATGW
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.primary.id
}
# Without NATGW

# # With NATGW
# resource "aws_eip" "nat" {
#   domain = "vpc"
# }

# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public_a_az.id
# }

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.primary.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }
# }
# # With NATGW

resource "aws_route_table_association" "public_a_az" {
  subnet_id      = aws_subnet.public_a_az.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b_az" {
  subnet_id      = aws_subnet.public_b_az.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a_az" {
  subnet_id      = aws_subnet.private_a_az.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b_az" {
  subnet_id      = aws_subnet.private_b_az.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "test_stack" {
  vpc_id = aws_vpc.primary.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "46.53.252.80/32", # TEMP
      aws_subnet.public_a_az.cidr_block,
      aws_subnet.public_b_az.cidr_block,
      aws_subnet.private_a_az.cidr_block,
      aws_subnet.private_b_az.cidr_block,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.primary.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "46.53.252.80/32",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.primary.id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_network_acl_association" "public_a_az" {
  subnet_id      = aws_subnet.public_a_az.id
  network_acl_id = aws_network_acl.public_nacl.id
}

resource "aws_network_acl_association" "public_b_az" {
  subnet_id      = aws_subnet.public_b_az.id
  network_acl_id = aws_network_acl.public_nacl.id
}
