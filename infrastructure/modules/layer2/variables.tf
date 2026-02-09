variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "layer1_state_key" {
  description = "Key for Layer 1 remote state"
  type        = string
}
