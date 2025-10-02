variable "region" {
  description = "AWS region (used to build endpoint service names)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for VPC endpoints"
  type        = string
}

variable "private_route_table_id" {
  description = "Private route table ID for gateway endpoints"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for interface endpoints"
  type        = list(string)
}

variable "endpoints_sg_id" {
  description = "Security group ID to attach to interface endpoints"
  type        = string
}


