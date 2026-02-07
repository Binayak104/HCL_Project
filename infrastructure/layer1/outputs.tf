output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "chroma_db_ip" {
  value = aws_instance.chroma_db.public_ip
}

output "chroma_sg_id" {
  value = aws_security_group.chroma_sg.id
}

output "ecr_backend_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_url" {
  value = aws_ecr_repository.frontend.repository_url
}
