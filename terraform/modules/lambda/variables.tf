variable "lambda_role_name" {
  type    = string
  default = "s3-events-lambda-role"
}

variable "input_bucket_arn" {
  type = string
}

variable "sqs_queue_arn" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}
