# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1b511abead59c6cee45d44c9f3d8aa3b5ed9f5a3"
  ]

  tags = {
    Name = "github-oidc-provider"
  }
}

# Single GitHub Actions role for both CI/CD and Terraform
resource "aws_iam_role" "github_actions" {
  name = "github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
          StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*" }
        }
      }
    ]
  })

  tags = { Name = "github-actions" }
}

# Unified policy with wildcard permissions for simplicity
resource "aws_iam_policy" "github_actions" {
  name        = "github-actions-policy"
  description = "Full permissions for GitHub Actions CI/CD and infrastructure management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "FullAccess"
        Effect = "Allow"
        Action = [
          "s3:*",
          "ecr:*",
          "ecs:*",
          "codedeploy:*",
          "dynamodb:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "logs:*",
          "cloudwatch:*",
          "acm:*",
          "route53:*",
          "wafv2:*",
          "iam:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
