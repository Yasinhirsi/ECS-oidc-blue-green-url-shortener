variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
}

variable "allow_all_cidr" {
  description = "CIDR used for open ingress rules (e.g., 0.0.0.0/0)"
  type        = string
}
