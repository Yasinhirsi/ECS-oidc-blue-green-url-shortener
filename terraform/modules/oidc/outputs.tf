output "github_actions_ci_role_arn" {
  description = "ARN of the GitHub Actions IAM role for CI/CD (app deployment)"
  value       = aws_iam_role.github_actions_ci.arn
}

output "github_actions_terraform_role_arn" {
  description = "ARN of the GitHub Actions IAM role for Terraform (infra management)"
  value       = aws_iam_role.github_actions_terraform.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}
