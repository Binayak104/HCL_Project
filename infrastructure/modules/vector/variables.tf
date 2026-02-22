variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for RDS"
  type        = list(string)
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
  default     = "password123"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
