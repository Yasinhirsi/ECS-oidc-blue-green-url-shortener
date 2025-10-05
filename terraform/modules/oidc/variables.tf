variable "github_repo" {
  description = "GitHub repository in format 'owner/repo' (e.g., 'CoderCo-Learning/url-shortener')"
  type        = string
}

variable "codedeploy_revisions_bucket_name" {
  description = "S3 bucket name that stores appspec.yml revisions for CodeDeploy"
  type        = string
  default     = "url-shortener-codedeploy-revisions"
}

variable "tf_state_bucket_name" {
  description = "S3 bucket name used for Terraform remote state"
  type        = string
  default     = "url-shortener-remote-tf-state"
}

variable "tf_lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking"
  type        = string
  default     = "terraform-state-lock"
}
