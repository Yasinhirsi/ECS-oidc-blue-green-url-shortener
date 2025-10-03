variable "github_repo" {
  description = "GitHub repository in format 'owner/repo' (e.g., 'CoderCo-Learning/url-shortener')"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy role"
  type        = string
}
