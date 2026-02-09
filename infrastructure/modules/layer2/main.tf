# --- Import Layer 1 State ---
data "terraform_remote_state" "layer1" {
  backend = "s3"
  config = {
    bucket = "hcl-project-tf-state-20260209130725265000000001"
    key    = var.layer1_state_key
    region = "us-east-1"
  }
}

# --- IAM Roles ---
resource "aws_iam_role" "lambda_role" {
  name = "hcl_project_lambda_role_layer2_${var.environment}"
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
  name = "hcl_project_apprunner_role_layer2_${var.environment}"
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

# --- Backend (Lambda + API Gateway) ---
resource "aws_lambda_function" "api" {
  function_name = "hcl-project-api-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${data.terraform_remote_state.layer1.outputs.ecr_backend_url}:latest"
  timeout       = 60
  memory_size   = 512

  environment {
    variables = {
      CHROMA_HOST = data.terraform_remote_state.layer1.outputs.chroma_db_ip
      CHROMA_PORT = "8000"
    }
  }
}

resource "aws_apigatewayv2_api" "api" {
  name          = "hcl-project-api-${var.environment}"
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
  service_name = "hcl-project-frontend-${var.environment}"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn
    }
    image_repository {
      image_identifier      = "${data.terraform_remote_state.layer1.outputs.ecr_frontend_url}:latest"
      image_repository_type = "ECR"
      image_configuration {
        port = "3000"
        runtime_environment_variables = {
            NEXT_PUBLIC_API_URL = aws_apigatewayv2_api.api.api_endpoint
            HOSTNAME            = "0.0.0.0"
        }
      }
    }
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/"
    interval            = 10
    timeout             = 20
    healthy_threshold   = 1
    unhealthy_threshold = 10
  }

  instance_configuration {
    cpu    = "1024"
    memory = "2048"
  }
  
  depends_on = [aws_iam_role_policy_attachment.apprunner_policy]
}

# --- S3 Buckets ---
resource "aws_s3_bucket" "data_bucket" {
  bucket_prefix = "hcl-project-data-${var.environment}-"
}
