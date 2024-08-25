resource "aws_vpc" "public_blockchain_vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "Public Chain VPC"
  }
}

resource "aws_subnet" "public_blockchain_subnet_public" {
  vpc_id = aws_vpc.public_blockchain_vpc.id
  cidr_block = var.public_subnet_cidr
  availability_zone = var.availability_zone_1

  tags = {
    Name = "Public Subnet"
  }
}

# Get the list of availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_blockchain_subnet_private" {
  count = 2
  vpc_id = aws_vpc.public_blockchain_vpc.id 
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index +1)
  availability_zone = data.aws_availability_zones.available.names[count.index + 1]

  tags = {
    Name = "Private Subnet ${count.index +1}"
  }
}


resource "aws_internet_gateway" "public_blockchain_gw" {
  vpc_id = aws_vpc.public_blockchain_vpc.id 

  tags = {
    Name = "Public Blockchain Internet Gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.public_blockchain_vpc.id 

  route{
    cidr_block = "0.0.0.0"
    gateway_id = aws_internet_gateway.public_blockchain_gw.id
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.public_blockchain_vpc.id   
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id = aws_subnet.public_blockchain_subnet_public.id 
  route_table_id = aws_route_table.public_route_table.id 
  gateway_id = aws_internet_gateway.public_blockchain_gw.id

}

resource "aws_route_table_association" "private_rt_association" {
  count = length(aws_subnet.public_blockchain_subnet_private)

  subnet_id     = aws_subnet.public_blockchain_subnet_private[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
