# modules/network/main.tf
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.prefix}-vpc" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone       = var.az_a
  map_public_ip_on_launch = true
  tags = { Name = "${var.prefix}-public-${var.az_a}" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = var.az_b
  map_public_ip_on_launch = true
  tags = { Name = "${var.prefix}-public-${var.az_b}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.prefix}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route { 
    cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id 
   }
  tags = { Name = "${var.prefix}-public-rt" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.prefix}-alb-sg"
  description = "Allow HTTP from allowed CIDRs"
  vpc_id      = aws_vpc.this.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.prefix}-alb-sg" }
}
