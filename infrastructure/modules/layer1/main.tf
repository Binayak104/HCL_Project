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
    Name = "hcl-project-layer1-subnet-${var.environment}"
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

# --- Security Group for RDS ---
resource "aws_security_group" "rds_sg" {
  name        = "hcl-project-rds-sg-layer1-${var.environment}"
  description = "Allow inbound traffic for RDS PostgreSQL"
  vpc_id      = data.aws_vpc.default.id

  # Allow access from within the VPC (e.g. Lambda, EC2)
  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- RDS Subnet Group ---
resource "aws_db_subnet_group" "main" {
  name       = "hcl-project-rds-subnet-group-${var.environment}"
  subnet_ids = [aws_subnet.public.id, data.aws_subnet.default_b.id] # RDS needs at least 2 AZs

  tags = {
    Name = "hcl-project-rds-subnet-group-${var.environment}"
  }
}

# Data source for another default subnet in a different AZ (RDS requirement)
data "aws_subnet" "default_b" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.aws_region}b"
}

# --- RDS PostgreSQL Instance ---
resource "aws_db_instance" "postgres" {
  identifier           = "hcl-project-db-${var.environment}"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "16" # Latest major version with pgvector support
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true
  publicly_accessible  = true # Set to true for simplicity in this project, ideally false
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "hcl-project-postgres-${var.environment}"
  }
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
