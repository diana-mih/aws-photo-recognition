# Terraform configuration for AWS provider
provider "aws" {
  region = "eu-west-1"
}

module "input_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "photo-pipeline-input-001"
}
