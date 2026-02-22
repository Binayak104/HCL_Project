output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "ecr_backend_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_url" {
  value = aws_ecr_repository.frontend.repository_url
}
