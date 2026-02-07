terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "hcl-project-tf-state-20260207093946259100000001"
    key            = "hcl-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hcl-project-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# --- VPC / Network (Using Default for Simplicity) ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- Security Group for ChromaDB ---
resource "aws_security_group" "chroma_sg" {
  name        = "hcl-project-chroma-sg"
  description = "Allow inbound traffic for ChromaDB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "ChromaDB from Lambda (and public for now)"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: Restrict to Lambda IP range or VPC in production
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: Restrict to User IP
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
  
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.chroma_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              
              # Run ChromaDB
              docker run -d -p 8000:8000 --name chroma_server chromadb/chroma:latest
              EOF

  tags = {
    Name = "hcl-project-chromadb"
  }
}

# --- ECR Repositories ---
resource "aws_ecr_repository" "backend" {
  name = "hcl-project-backend"
  force_delete = true
}

resource "aws_ecr_repository" "frontend" {
  name = "hcl-project-frontend"
  force_delete = true
}

# --- S3 Buckets ---
resource "aws_s3_bucket" "data_bucket" {
  bucket_prefix = "hcl-project-data-"
}

# --- Backend (Lambda + API Gateway) ---
resource "aws_lambda_function" "api" {
  function_name = "hcl-project-api"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  # This serves as a placeholder. You must push an image to ECR before applying,
  # or use a dummy image initially.
  image_uri     = "${aws_ecr_repository.backend.repository_url}:latest"
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {
      CHROMA_HOST = aws_instance.chroma_db.public_ip 
      CHROMA_PORT = "8000"
    }
  }
}

resource "aws_apigatewayv2_api" "api" {
  name          = "hcl-project-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "api" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.api.invoke_arn
}

resource "aws_apigatewayv2_route" "api" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.api.id}"
}

resource "aws_apigatewayv2_stage" "api" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# --- Frontend (App Runner) ---
resource "aws_apprunner_service" "frontend" {
  service_name = "hcl-project-frontend"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn
    }
    image_repository {
      image_identifier      = "${aws_ecr_repository.frontend.repository_url}:latest"
      image_repository_type = "ECR"
      image_configuration {
        port = "3000"
        runtime_environment_variables = {
            NEXT_PUBLIC_API_URL = aws_apigatewayv2_api.api.api_endpoint
        }
      }
    }
  }
  
  depends_on = [aws_iam_role_policy_attachment.apprunner_policy]
}

# --- IAM Roles ---
resource "aws_iam_role" "lambda_role" {
  name = "hcl_project_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_bedrock" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess" # Scope down in production
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role" "apprunner_role" {
  name = "hcl_project_apprunner_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "build.apprunner.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
  role       = aws_iam_role.apprunner_role.name
}
