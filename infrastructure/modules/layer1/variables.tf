variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the primary subnet"
  type        = string
}

variable "cidr_block_b" {
  description = "CIDR block for the secondary subnet"
  type        = string
}
