# Terraform configuration for AWS provider
provider "aws" {
  region = "eu-west-1"
}

module "input_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "photo-pipeline-input-001"
}

module "sqs" {
  source        = "./modules/sqs"
  queue_name    = "s3-events-queue"
  dlq_arn       = module.sqs.dlq_arn
  s3_bucket_arn = module.input_bucket.bucket_arn
}


module "lambda" {
  source = "./modules/lambda"

  input_bucket_arn   = module.input_bucket.bucket_arn
  sqs_queue_arn      = module.sqs.queue_arn
  dynamodb_table_arn = aws_dynamodb_table.photos_table.arn
}

