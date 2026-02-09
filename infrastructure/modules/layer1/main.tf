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

# --- Security Group for ChromaDB ---
resource "aws_security_group" "chroma_sg" {
  name        = "hcl-project-chroma-sg-layer1-${var.environment}"
  description = "Allow inbound traffic for ChromaDB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "ChromaDB from Public"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- EC2 Instance for ChromaDB ---
resource "aws_instance" "chroma_db" {
  ami           = "ami-0ebfd941bbafe70c6" # Amazon Linux 2023 AMI in us-east-1
  instance_type = "t2.micro"
  key_name      = "key-16-11-2025"
  
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.chroma_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              
              # Run ChromaDB
              docker run -d -p 8000:8000 --name chroma_server chromadb/chroma:0.5.20
              EOF

  tags = {
    Name = "hcl-project-chromadb-${var.environment}"
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
