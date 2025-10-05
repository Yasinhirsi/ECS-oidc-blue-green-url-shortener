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

resource "aws_iam_role" "github_actions_ci" {
  name = "github-actions-ci"

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

  tags = { Name = "github-actions-ci" }
}

# Read-only across AWS for CI to avoid AccessDenied on describe/list
resource "aws_iam_role_policy_attachment" "ci_readonly" {
  role       = aws_iam_role.github_actions_ci.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ECR push/pull permissions for CI
resource "aws_iam_role_policy_attachment" "ci_ecr_poweruser" {
  role       = aws_iam_role.github_actions_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# Minimal write actions for CI deployments (ECS/CodeDeploy + PassRole)
resource "aws_iam_policy" "ci_writes" {
  name        = "github-actions-ci-writes"
  description = "Minimal write permissions for CI deploys"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECSRegisterAndUpdate"
        Effect = "Allow"
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeServices",
          "ecs:UpdateService"
        ]
        Resource = "*"
      },
      {
        Sid    = "CodeDeployStartAndRead"
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetApplication",
          "codedeploy:GetDeploymentGroup"
        ]
        Resource = "*"
      },
      {
        Sid      = "PassTaskRolesToECS"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = { "iam:PassedToService" = "ecs-tasks.amazonaws.com" }
        }
      },
      {
        Sid    = "S3CodeDeployBucket"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::url-shortener-codedeploy-revisions",
          "arn:aws:s3:::url-shortener-codedeploy-revisions/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ci_writes_attach" {
  role       = aws_iam_role.github_actions_ci.name
  policy_arn = aws_iam_policy.ci_writes.arn
}

# Separate Terraform role with broad permissions (can be tightened later)
resource "aws_iam_role" "github_actions_terraform" {
  name = "github-actions-terraform"

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

  tags = { Name = "github-actions-terraform" }
}

resource "aws_iam_policy" "terraform" {
  name        = "github-actions-terraform-policy"
  description = "Scoped permissions for Terraform to manage infrastructure"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "acm:*",
          "route53:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "ecs:*",
          "codedeploy:*",
          "dynamodb:*",
          "wafv2:*",
          "logs:*",
          "cloudwatch:*",
          "iam:*",
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tf_policy" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.terraform.arn
}
