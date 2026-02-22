terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "hcl-project-tf-state-20260219115130774700000001"
    key            = "hcl-project/vector/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hcl-project-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "layer1" {
  backend = "s3"
  config = {
    bucket = "hcl-project-tf-state-20260219115130774700000001"
    key    = "hcl-project/layer1/terraform.tfstate"
    region = "us-east-1"
  }
}

module "vector" {
  source      = "../modules/vector"
  environment = "main"
  vpc_id      = data.terraform_remote_state.layer1.outputs.vpc_id
  # Use the two subnets managed by Layer 1
  subnet_ids  = [
    data.terraform_remote_state.layer1.outputs.subnet_id,
    data.terraform_remote_state.layer1.outputs.subnet_id_b
  ]
}

output "db_endpoint" {
  value = module.vector.db_endpoint
}

output "db_name" {
  value = module.vector.db_name
}

output "db_username" {
  value = module.vector.db_username
}

output "db_password" {
  value     = module.vector.db_password
  sensitive = true
}
