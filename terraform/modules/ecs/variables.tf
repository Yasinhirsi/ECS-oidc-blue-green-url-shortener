variable "cluster_name" { type = string }

variable "family" { type = string }
variable "cpu" { type = number }
variable "memory" { type = number }
variable "image" { type = string }
variable "app_port" { type = number }

variable "aws_region" { type = string }
variable "log_stream_prefix" { type = string }

variable "table_name" { type = string }
variable "ddb_table_arn" { type = string }

variable "private_subnet_ids" { type = list(string) }
variable "ecs_sg_id" { type = string }

variable "target_group_arn" { type = string }
variable "desired_count" { type = number }


