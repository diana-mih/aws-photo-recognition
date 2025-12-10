
# Create an IAM Role that GitHub Actions will assume
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-terraform-role"

  # Trust policy: allows GitHub OIDC provider to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        # The "sub" condition restricts which GitHub repo can assume the role
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:diana-mih/aws-photo-recognition:*"
          }
        }
      }
    ]
  })
  depends_on = [aws_iam_openid_connect_provider.github]
}

# Create the GitHub OIDC provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  # GitHub provides this official thumbprint
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  client_id_list = ["sts.amazonaws.com"]
}

# Add permissions to the role
resource "aws_iam_role_policy" "github_actions_policy" {
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow Terraform to manage AWS resources
      {
        Effect   = "Allow"
        Action   = ["*"]
        Resource = "*"
      }
    ]
  })
}
