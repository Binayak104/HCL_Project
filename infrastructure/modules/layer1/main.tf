# --- Network (Default VPC + Dedicated Subnet) ---

data "aws_vpc" "default" {
  default = true
}

resource "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "hcl-project-layer1-subnet-a-${var.environment}"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = var.cidr_block_b
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}b"
  tags = {
    Name = "hcl-project-layer1-subnet-b-${var.environment}"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = "hcl-project-igw-${var.environment}"
  }
}

# --- Route Table ---
resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "hcl-project-public-rt-${var.environment}"
  }
}

# --- Route Table Association ---
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}


# --- ECR Repositories ---
resource "aws_ecr_repository" "backend" {
  name = "hcl-project-backend-${var.environment}"
  force_delete = true
}

resource "aws_ecr_repository" "frontend" {
  name = "hcl-project-frontend-${var.environment}"
  force_delete = true
}
