variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to watch for object creation."
}

variable "sqs_queue_arn" {
  type        = string
  description = "ARN of the SQS queue that will receive EventBridge messages."
}

variable "sqs_queue_url" {
  type        = string
  description = "URL of the SQS queue."
}

variable "rule_name" {
  type        = string
  description = "Name of the EventBridge rule."
  default     = "s3-object-created"
}
