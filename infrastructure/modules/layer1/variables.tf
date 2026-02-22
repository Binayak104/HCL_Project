variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "vecdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  default     = "password123" # In production, use secrets manager or CI/CD secrets
}
