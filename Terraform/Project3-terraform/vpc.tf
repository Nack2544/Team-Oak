terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "hharmon-terraform-proj3-test-bucket"
    key    = "terrform.tfstate"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = var.default_tags
  }
}

# Create a VPC: cidr 10.0.0.0/16
resource "aws_vpc" "main" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    "Name" = "hharmon"
  }
}


# Public Subnet: cidr 10.0.0.0/24
#                cidr 10.0.1.0/24
resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index) # prefix, newbits, netnum
  ipv6_cidr_block         = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.default_tags.env}-Public-subnet-${data.aws_availability_zones.availability_zone.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index] # specifying the AZ the subnet is in
}

# Private Subnet: cidr 10.0.2.0/24
#                 cidr 10.0.3.0/24
resource "aws_subnet" "private" {
  count      = var.private_subnet_count
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.public_subnet_count) # prefix, newbits, netnum
  tags = {
    "Name" = "${var.default_tags.env}-Private-subnet-${data.aws_availability_zones.availability_zone.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index] # specifying the AZ the subnet is in
}

# IGW
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-IGW"
  }
}

# EIP
resource "aws_eip" "NAT_EIP" {
  vpc = true
}
# NAT Gateway
resource "aws_nat_gateway" "main_nat_gw" {
  allocation_id = aws_eip.NAT_EIP.id
  subnet_id     = aws_subnet.public.0.id
  tags = {
    "Name" = "${var.default_tags.env}-nat"
  }
}

# Public RT
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-public_rt"
  }
}

# Route for our public RT
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

# Route table Associations
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public_rt.id
  count          = var.public_subnet_count
  subnet_id      = element(aws_subnet.public.*.id, count.index) # list, index
}

# Private RT
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-private_rt"
  }
}


# Route for our private RT
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.main_nat_gw.id
}

# Route table Associations
resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private_rt.id
  count          = var.private_subnet_count
  subnet_id      = element(aws_subnet.private.*.id, count.index) # list, index
}

# AWS ECR repository
resource "aws_ecr_repository" "foo" {
  name                 = "bar" # insert name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    "Name" = "${var.default_tags.env}-private_rt"
    env = "dev"
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  }