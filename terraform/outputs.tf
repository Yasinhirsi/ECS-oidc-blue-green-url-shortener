output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "github_actions_ci_role_arn" {
  description = "ARN of the GitHub Actions IAM role for CI/CD"
  value       = module.oidc.github_actions_ci_role_arn
}

output "github_actions_terraform_role_arn" {
  description = "ARN of the GitHub Actions IAM role for Terraform"
  value       = module.oidc.github_actions_terraform_role_arn
}


