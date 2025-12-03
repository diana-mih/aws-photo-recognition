# DynamoDB table for storing photo metadata
resource "aws_dynamodb_table" "photos_table" {
  name         = "photos_metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "object_key"

  attribute {
    name = "object_key"
    type = "S"
  }
}
