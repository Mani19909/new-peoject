# Create VPC 
resource "aws_vpc" "vpc"{
cidr_block = var.vpc_cidr
enable_dns_hostnames = "true"
tags={
Name = "devops-vpc"
}
}
# Internet Gateway 

resource "aws_internet_gateway" "igw"{
  vpc_id = aws_vpc.vpc.id
}
# NAT Gateway setup requires Elastic IP
resource "aws_eip" "nat_eip" {
}
# NAT Gateway
resource "aws_nat_gateway" "nat"{
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public.id
  tags= {
    Name = "devops-nat-gateway"
  }
}
# Create public subnet
resource "aws_subnet" "public"{
vpc_id = aws_vpc.vpc.id
cidr_block = var.public_subnet_cidr
map_public_ip_on_launch = "true"
availability_zone = "us-east-1a"
tags = {
Name = "devops-public-subnet"
}
}
#create private subnet
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = "devops-private-subnet"
  }
}
# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_assoc"{
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_route_table" "public_rt"{
vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "internet_access" {
route_table_id = aws_route_table.public_rt.id
destination_cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "public_assco"{
subnet_id = aws_subnet.public.id
route_table_id = aws_route_table.public_rt.id
}

resource "aws_instance" "jenkins"{
ami = "ami-08a6efd148b1f7504"
instance_type = "t2.micro"
subnet_id = aws_subnet.public.id
associate_public_ip_address = "true"
key_name = "master"

tags= {
Name = "jenkins-server"
}
}



































