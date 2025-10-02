// security_groups.tf outputs
output "alb_sg_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb_sg.id
}

output "ecs_sg_id" {
  description = "ECS tasks security group ID"
  value       = aws_security_group.ecs_sg.id
}

output "endpoints_sg_id" {
  description = "VPC endpoints security group ID"
  value       = aws_security_group.endpoints_sg.id
}
