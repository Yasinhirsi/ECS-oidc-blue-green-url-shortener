output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc_ecs_url.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [aws_subnet.public_sub1.id, aws_subnet.public_sub2.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = [aws_subnet.private_sub1.id, aws_subnet.private_sub2.id]
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public_route_table.id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.private_route_table.id
}
