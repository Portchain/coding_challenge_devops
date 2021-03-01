# Create VPC, subnet, IGW and associate route
resource "aws_vpc" "portchain_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "portchain_vpc"
  }
}

resource "aws_subnet" "portchain_subnet" {
  vpc_id            = aws_vpc.portchain_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "portchain_subnet"
  }
}

resource "aws_internet_gateway" "portchain_igw" {
  vpc_id = aws_vpc.portchain_vpc.id

  tags = {
    Name = "portchain_igw"
  }
}

resource "aws_route" "r" {
  route_table_id  = aws_vpc.portchain_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id      = aws_internet_gateway.portchain_igw.id
}