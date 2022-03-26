resource "aws_subnet" "myapp-subnet" {
  vpc_id            = var.vpc_id
  availability_zone = var.az
  cidr_block        = var.subnet_cidr_block
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

// using the default route table created by our vpc and associating the internet gateway to our route table
resource "aws_default_route_table" "myapp-rtb" {
  default_route_table_id = var.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}
