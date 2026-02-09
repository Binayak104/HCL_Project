terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "hcl-project-tf-state-20260209130725265000000001"
    key            = "hcl-project/layer2/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hcl-project-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "layer2" {
  source           = "../../modules/layer2"
  environment      = "dev"
  layer1_state_key = "hcl-project/layer1/dev/terraform.tfstate"
}

output "api_endpoint" {
  value = module.layer2.api_endpoint
}

output "frontend_service_url" {
  value = module.layer2.frontend_service_url
}
