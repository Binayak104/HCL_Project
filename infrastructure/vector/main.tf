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

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.layer1.outputs.vpc_id]
  }
}

module "vector" {
  source      = "../modules/vector"
  environment = "main"
  vpc_id      = data.terraform_remote_state.layer1.outputs.vpc_id
  # Use the subnet from Layer 1 PLUS any other subnets found in the VPC to satisfy RDS Multi-AZ requirement
  subnet_ids  = distinct(concat([data.terraform_remote_state.layer1.outputs.subnet_id], data.aws_subnets.all.ids))
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
