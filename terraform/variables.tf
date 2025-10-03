variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_sub1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_sub2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_sub1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_sub2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "10.0.4.0/24"
}

variable "subnet_1_az" {
  description = "Availability zone for subnet 1"
  type        = string
  default     = "eu-west-2a"
}

variable "subnet_2_az" {
  description = "Availability zone for subnet 2"
  type        = string
  default     = "eu-west-2b"
}

variable "allow_all_cidr" {
  description = "CIDR used for open ingress rules (e.g., 0.0.0.0/0)"
  type        = string
  default     = "0.0.0.0/0"
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

variable "github_repo" {
  description = "GitHub repository in format 'owner/repo' (e.g., 'Yasinhirsi/ECS-oidc-blue-green-url-shortener')"
  type        = string
  default     = "Yasinhirsi/ECS-oidc-blue-green-url-shortener"
}
