resource "aws_vpc" "win_srv_vpc" {
  cidr_block           = var.base_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name"      = "${var.env_prefix}_vpc"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

resource "aws_subnet" "win_srv_public_subnet" {
  vpc_id                  = aws_vpc.win_srv_vpc.id
  cidr_block              = cidrsubnet(var.base_cidr_block, 8, 1)
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    "Name"      = "${var.env_prefix}_public_subnet"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

resource "aws_internet_gateway" "win_srv_igw" {
  vpc_id = aws_vpc.win_srv_vpc.id

  tags = {
    "Name"      = "${var.env_prefix}_vpc_igw"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

resource "aws_route_table" "win_srv_public_subnet_rt" {
  vpc_id = aws_vpc.win_srv_vpc.id
  tags = {
    "Name"      = "${var.env_prefix}_public_subnet_rt"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

resource "aws_route" "win_srv_public_subnet_route" {
  route_table_id         = aws_route_table.win_srv_public_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.win_srv_igw.id
}

resource "aws_route_table_association" "win_srv_route_assoc" {
  subnet_id      = aws_subnet.win_srv_public_subnet.id
  route_table_id = aws_route_table.win_srv_public_subnet_rt.id
}
