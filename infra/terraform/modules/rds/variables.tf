variable "name_prefix" { type = string }
variable "subnet_ids" { type = list(string) }
variable "db_security_group_id" { type = string }
variable "db_password" { type = string, sensitive = true }