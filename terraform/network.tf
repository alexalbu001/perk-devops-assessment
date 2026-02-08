# Internet Gateway for public subnets (required for ALB)
resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.main.id
}

# Create private subnets
resource "aws_subnet" "private" {
  count = 3

  vpc_id            = data.aws_vpc.main.id
  cidr_block        = ["172.31.48.0/20", "172.31.64.0/20", "172.31.80.0/20"][count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway in first public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = data.aws_subnets.public.ids[0]

  depends_on = [aws_internet_gateway.main]
}

# Route table for private subnets (routes to NAT Gateway)
resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count = length(data.aws_subnets.public.ids)

  subnet_id      = data.aws_subnets.public.ids[count.index]
  route_table_id = aws_route_table.public.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
