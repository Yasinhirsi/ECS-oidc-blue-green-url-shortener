variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_sub1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
}

variable "public_sub2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
}

variable "private_sub1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
}

variable "private_sub2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
}

variable "subnet_1_az" {
  description = "Availability zone for subnet 1"
  type        = string
}

variable "subnet_2_az" {
  description = "Availability zone for subnet 2"
  type        = string
}

variable "allow_all_cidr" {
  description = "CIDR used for open ingress rules (e.g., 0.0.0.0/0)"
  type        = string
}

variable "desired_count" {
  description = "Number of desired tasks in the ECS service"
  type        = number
  default     = 2
}


variable "domain_name" {
  description = "name of domain hosting the app"
  type        = string
  default     = "tm.yasinhirsi.com"
}
