# --- Security Group for RDS ---
resource "aws_security_group" "rds_sg" {
  name        = "hcl-project-rds-sg-vector-${var.environment}"
  description = "Allow inbound traffic for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

# --- RDS Subnet Group ---
resource "aws_db_subnet_group" "main" {
  name       = "hcl-project-rds-subnet-group-${var.environment}"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "hcl-project-rds-subnet-group-${var.environment}"
  }
}

# --- RDS PostgreSQL Instance ---
resource "aws_db_instance" "postgres" {
  identifier           = "hcl-project-db-${var.environment}"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "16"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true
  publicly_accessible  = true
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "hcl-project-postgres-${var.environment}"
  }
}
