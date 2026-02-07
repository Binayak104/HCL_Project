output "api_endpoint" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

output "frontend_url" {
  value = aws_apprunner_service.frontend.service_url
}

output "backend_repo_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "frontend_repo_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "chromadb_ip" {
  value = aws_instance.chroma_db.public_ip
}
