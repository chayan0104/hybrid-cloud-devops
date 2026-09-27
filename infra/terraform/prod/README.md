# Terraform PROD Environment

Location: `infra/terraform/prod/`

## What It Provisions

- VPC and subnets
- Security groups
- ALB
- EC2 WebLogic monolith tier
- EKS frontend + microservice tier
- RDS MySQL with the `app_db` database

## Inputs

Use `terraform.tfvars` (from `terraform.tfvars.example`) for environment values. It contains a sensitive DB password; do not commit the copied file. The current stack has no remote backend, so protect the local state file.

## Commands

```bash
cd infra/terraform/prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform output
```