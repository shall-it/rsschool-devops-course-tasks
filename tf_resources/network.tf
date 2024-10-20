
# task_2

locals {
  public_subnets = {
    public_a = { cidr_block = "10.0.11.0/24", az = "us-east-1a" }
    public_b = { cidr_block = "10.0.12.0/24", az = "us-east-1b" }
  }

  private_subnets = {
    private_a = { cidr_block = "10.0.21.0/24", az = "us-east-1a" }
    private_b = { cidr_block = "10.0.22.0/24", az = "us-east-1b" }
  }
}

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
  cidr_block           = var.primary_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  for_each          = local.private_subnets
  vpc_id            = aws_vpc.primary.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.primary.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.primary.id

  route {
    cidr_block = var.global_cidr_block
    gateway_id = aws_internet_gateway.public.id
  }
}

#WITHOUT NAT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.primary.id
}
#WITHOUT NAT

# # #WITH NAT
# resource "aws_eip" "nat" {
#   domain = "vpc"
# }

# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public["public_a"].id
# }

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.primary.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }
# }
# # #WITH NAT

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "common" {
  vpc_id = aws_vpc.primary.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.global_cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.global_cidr_block]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = flatten([
      for subnet in concat(
        [for s in aws_subnet.public : s.cidr_block],
        [for s in aws_subnet.private : s.cidr_block]
      ) : subnet
    ])
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.global_cidr_block]
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.primary.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.personal_ip]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.personal_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.global_cidr_block]
  }
}

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.primary.id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = var.global_cidr_block
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = var.global_cidr_block
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.primary.id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = var.global_cidr_block
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = var.global_cidr_block
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_network_acl_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.public.id
}

resource "aws_network_acl_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.private.id
}
