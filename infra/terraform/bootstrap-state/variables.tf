variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "state_bucket_name" {
  type    = string
  default = "hybrid-cloud-terraform-state-prod"
}

variable "lock_table_name" {
  type    = string
  default = "hybrid-cloud-terraform-locks"
}