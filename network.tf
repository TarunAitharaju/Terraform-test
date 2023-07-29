// VPC Resource
resource "aws_vpc" "vpc" {
  cidr_block           = var.aws_vpc-cidr
  enable_dns_hostnames = true
  tags = {
    Name = var.aws_vpc_name
  }
}

// Public Subnet Resource
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.aws_subnet_public_cidr

  tags = {
    Name = var.aws_subnet_name_public
  }
}


// Private Subnet Resource
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.aws_subnet_private_cidr

  tags = {
    Name = var.aws_subnet_name_private
  }
}

// Internet Gateway
resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.aws_igw_name
  }
}

// AWS Elastic IP
resource "aws_eip" "nat" {
  domain = "vpc"
}

// Public NAT gateway for Private Subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "Terraform NAT Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet]
}

// IGW Route table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet.id
  }

  tags = {
    Name = "${var.aws_roting_table_name}"
  }
}

resource "aws_route_table_association" "route_table" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public_route.id
}

// NAT Route table
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "NAT Gateway Route Table"
  }
}

resource "aws_route_table_association" "nat_route" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

