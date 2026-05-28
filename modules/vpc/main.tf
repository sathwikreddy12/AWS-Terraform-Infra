# modules/vpc/main.tf

# ─── VPC ────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr        # using variable, not hardcoded
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.environment}-vpc"     # "dev-vpc" or "prod-vpc"
    ManagedBy = "terraform"
  }
}

# ─── PUBLIC SUBNETS ─────────────────────────────────────────
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)    # creates ONE subnet per CIDR in the list

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true             # public = instances get public IPs

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
    Type = "public"
  }
}

# ─── PRIVATE SUBNETS ────────────────────────────────────────
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  # NO map_public_ip_on_launch — private subnets never get public IPs

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
    Type = "private"
  }
}

# ─── INTERNET GATEWAY ───────────────────────────────────────
# Allows public subnets to reach the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# ─── PUBLIC ROUTE TABLE ─────────────────────────────────────
# Rule: all internet traffic (0.0.0.0/0) goes via the IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                        # all internet traffic
    gateway_id = aws_internet_gateway.main.id        # goes through IGW
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# ─── ASSOCIATE PUBLIC SUBNETS WITH PUBLIC ROUTE TABLE ───────
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ─── ELASTIC IP for NAT Gateway ─────────────────────────────
# NAT Gateway needs a static public IP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

# ─── NAT GATEWAY ────────────────────────────────────────────
# Allows PRIVATE subnets to reach internet (for updates etc)
# but internet cannot initiate connections INTO private subnets
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id   # NAT lives in public subnet

  tags = {
    Name = "${var.environment}-nat"
  }

  depends_on = [aws_internet_gateway.main]  # IGW must exist before NAT
}

# ─── PRIVATE ROUTE TABLE ────────────────────────────────────
# Private subnets go to internet via NAT (not IGW directly)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id   # goes through NAT, not IGW
  }

  tags = {
    Name = "${var.environment}-private-rt"
  }
}

# ─── ASSOCIATE PRIVATE SUBNETS WITH PRIVATE ROUTE TABLE ─────
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

