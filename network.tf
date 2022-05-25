#Create VPC
resource "aws_vpc" "vpc_useast" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "rstudio-vpc"
  }

}

#Get all available AZ's in VPC 
data "aws_availability_zones" "azs" {
  state = "available"
}

#Create Subnet
resource "aws_subnet" "subnet_1" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_useast.id
  cidr_block        = "10.0.1.0/24"
}

#Create SG for allowing TCP/3939 from * and TCP/22 from your IP
resource "aws_security_group" "rstudio-sg" {
  name        = "rstudio-sg"
  description = "Allow TCP/3939 & TCP/22"
  vpc_id      = aws_vpc.vpc_useast.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "allow anyone on port 3939"
    from_port   = 3939
    to_port     = 3939
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_useast.id
}

#Create route table
resource "aws_route_table" "internet_route" {
  vpc_id = aws_vpc.vpc_useast.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "RStudio-RT"
  }
}

#Overwrite default route table of VPC(Master) with our route table entries
resource "aws_main_route_table_association" "set-rstudio-default-rt-assoc" {
  vpc_id         = aws_vpc.vpc_useast.id
  route_table_id = aws_route_table.internet_route.id
}