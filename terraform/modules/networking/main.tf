//Networking

resource "aws_vpc" "vpc_ecs_url" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-url-v2"
  }
}

resource "aws_internet_gateway" "igw_ecs_url" {
  vpc_id = aws_vpc.vpc_ecs_url.id

  tags = {
    Name = "igw-url-v2"
  }
}

resource "aws_subnet" "public_sub1" {
  vpc_id                  = aws_vpc.vpc_ecs_url.id
  cidr_block              = var.public_sub1_cidr
  availability_zone       = var.subnet_1_az
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1-v2"
  }
}

resource "aws_subnet" "public_sub2" {
  vpc_id                  = aws_vpc.vpc_ecs_url.id
  cidr_block              = var.public_sub2_cidr
  availability_zone       = var.subnet_2_az
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2-v2"
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_ecs_url.id

  route {
    cidr_block = var.allow_all_cidr
    gateway_id = aws_internet_gateway.igw_ecs_url.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_association1" {
  subnet_id      = aws_subnet.public_sub1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association2" {
  subnet_id      = aws_subnet.public_sub2.id
  route_table_id = aws_route_table.public_route_table.id
}




resource "aws_subnet" "private_sub1" {
  vpc_id            = aws_vpc.vpc_ecs_url.id
  cidr_block        = var.private_sub1_cidr
  availability_zone = var.subnet_1_az


  tags = {
    Name = "private-subnet-1-v2"
  }
}


resource "aws_subnet" "private_sub2" {
  vpc_id            = aws_vpc.vpc_ecs_url.id
  cidr_block        = var.private_sub2_cidr
  availability_zone = var.subnet_2_az

  tags = {
    Name = "private-subnet-2-v2"
  }
}



resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_ecs_url.id

  tags = {
    Name = "private-route-table"
  }
}



resource "aws_route_table_association" "private_asso1" {
  subnet_id      = aws_subnet.private_sub1.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_route_table_association" "private_asso2" {
  subnet_id      = aws_subnet.private_sub2.id
  route_table_id = aws_route_table.private_route_table.id
}
