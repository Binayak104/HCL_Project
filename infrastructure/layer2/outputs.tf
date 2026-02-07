output "api_endpoint" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

output "frontend_url" {
  value = aws_apprunner_service.frontend.service_url
}
