# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "s3-events-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Combined IAM policy for Lambda (SQS + S3 + Logs + Dynamodb + Rekognition)
resource "aws_iam_role_policy" "lambda_combined_policy" {
  name = "s3-events-lambda-combined-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # --- SQS ---
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ],
        Resource = aws_sqs_queue.s3_events.arn
      },

      # --- CloudWatch Logs ---
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },

      # --- S3 access ---
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::photo-pipeline-input-001",
          "arn:aws:s3:::photo-pipeline-input-001/*"
        ]
      },

      # --- Rekognition ---
      {
        Effect = "Allow",
        Action = [
          "rekognition:DetectLabels",
          "rekognition:DetectModerationLabels"
        ],
        Resource = "*"
      },

      # --- DynamoDB ---
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ],
        Resource = aws_dynamodb_table.photos_table.arn
      }
    ]
  })
}

# Lambda function
resource "aws_lambda_function" "s3_events_processor" {
  function_name = "s3-events-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename    = "../lambda/lambda.zip"
  memory_size = 256
  timeout     = 15

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  depends_on = [
    aws_s3_bucket.photos_input,
    aws_sqs_queue.s3_events
  ]
}

# SQS → Lambda
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.s3_events.arn
  function_name    = aws_lambda_function.s3_events_processor.arn
  batch_size       = 1
  enabled          = true

  depends_on = [
    aws_lambda_function.s3_events_processor,
    aws_sqs_queue.s3_events
  ]
}
