# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "s3-events-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda execution role
resource "aws_iam_role" "lambda_role" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# IAM policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "s3-events-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.s3_events.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::photo-pipeline-input-001/*"
      },
      {
        Effect = "Allow"
        Action = [
          "rekognition:DetectLabels"
        ],
        Resource = "*"
      }
    ]
  })
}

# Policy for DynamoDB access
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        Resource = aws_dynamodb_table.photos_table.arn
      }
    ]
  })
}

# Attach CloudWatch Logs policy
resource "aws_iam_role_policy" "lambda_logs_policy" {
  name = "lambda-logs-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Python Lambda function to process S3 events from SQS
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

# Map SQS as event source for Lambda
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