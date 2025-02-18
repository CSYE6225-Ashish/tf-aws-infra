terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.87.0, < 7.0.0"
    }
  }

  required_version = ">= 1.2.0"

}


provider "aws" {
  profile = var.profile
  region  = var.region
}


data "aws_availability_zones" "available" {}



resource "aws_vpc" "main" {
  cidr_block = var.vpc.cidr # Replace with your desired CIDR block
  tags = {
    Name = var.vpc.name
  }
}


resource "aws_subnet" "public" {
  count                   = local.zone_logic
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, local.new_bit, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }

}

resource "aws_subnet" "private" {
  count                   = local.zone_logic
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, local.new_bit, (count.index + local.zone_logic))
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }

}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Internet Gateway for ${aws_vpc.main.id}"
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateway.id
  }
  tags = {
    Name = "Public route table for ${aws_vpc.main.id}"
  }
}

resource "aws_route_table_association" "aws_route_table_public" {
  for_each       = local.public_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Private route table for ${aws_vpc.main.id}"
  }
}

resource "aws_route_table_association" "aws_route_table_private" {
  for_each       = local.private_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.private_route_table.id
}

