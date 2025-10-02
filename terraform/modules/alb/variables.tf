variable "vpc_id" {
  description = "VPC ID where ALB and target groups exist"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "alb_name" {
  description = "ALB name"
  type        = string
  default     = "url-alb"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on ALB"
  type        = bool
  default     = false
}

variable "app_port" {
  description = "Application port for target groups"
  type        = number
  default     = 8080
}

variable "healthcheck_path" {
  description = "Health check path for target groups"
  type        = string
  default     = "/healthz"
}



