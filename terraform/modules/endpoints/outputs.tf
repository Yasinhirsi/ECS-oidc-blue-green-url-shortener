// endpoints.tf outputs
output "s3_endpoint_id" {
  description = "VPC Endpoint ID for S3"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "VPC Endpoint ID for DynamoDB"
  value       = aws_vpc_endpoint.DynamoDB.id
}

output "ecs_endpoint_id" {
  description = "Interface endpoint ID for ECS"
  value       = aws_vpc_endpoint.ecs.id
}

output "ecr_dkr_endpoint_id" {
  description = "Interface endpoint ID for ECR DKR"
  value       = aws_vpc_endpoint.ecr.id
}

output "ecr_api_endpoint_id" {
  description = "Interface endpoint ID for ECR API"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "logs_endpoint_id" {
  description = "Interface endpoint ID for CloudWatch Logs"
  value       = aws_vpc_endpoint.logs.id
}


