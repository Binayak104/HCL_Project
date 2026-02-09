terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "hcl-project-tf-state-20260209130725265000000001"
    key            = "hcl-project/layer1/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hcl-project-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "layer1" {
  source      = "../../modules/layer1"
  environment = "dev"
  cidr_block  = "172.31.100.0/24"
}

output "subnet_id" {
  value = module.layer1.subnet_id
}

output "chroma_db_ip" {
  value = module.layer1.chroma_db_ip
}

output "ecr_backend_url" {
  value = module.layer1.ecr_backend_url
}

output "ecr_frontend_url" {
  value = module.layer1.ecr_frontend_url
}
