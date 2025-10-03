output "codedeploy_app_name" {
  description = "CodeDeploy application name"
  value       = aws_codedeploy_app.url_shortener_codedeploy_app.name
}

output "codedeploy_deployment_group_name" {
  description = "CodeDeploy deployment group name"
  value       = aws_codedeploy_deployment_group.url_dg.deployment_group_name
}

output "codedeploy_deployment_group_id" {
  description = "CodeDeploy deployment group ID"
  value       = aws_codedeploy_deployment_group.url_dg.id
}

output "codedeploy_role_arn" {
  description = "CodeDeploy role ARN"
  value       = aws_iam_role.codedeploy_role.arn
}


