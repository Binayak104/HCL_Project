terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "hcl-project-tf-state-20260219115130774700000001"
    key            = "hcl-project/layer1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hcl-project-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "layer1" {
  source       = "../modules/layer1"
  environment  = "main"
  cidr_block   = "172.31.200.0/24"
  cidr_block_b = "172.31.201.0/24"
}

output "vpc_id" {
  value = module.layer1.vpc_id
}

output "subnet_id" {
  value = module.layer1.subnet_id
}

output "subnet_id_b" {
  value = module.layer1.subnet_id_b
}

output "ecr_backend_url" {
  value = module.layer1.ecr_backend_url
}

output "ecr_frontend_url" {
  value = module.layer1.ecr_frontend_url
}
