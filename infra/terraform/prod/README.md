# Terraform PROD Environment

Location: `infra/terraform/prod/`

## What It Provisions

- VPC and subnets
- Security groups
- ALB
- EC2 Tomcat monolith tier
- EKS frontend + microservice tier
- RDS PostgreSQL

## Inputs

Use `terraform.tfvars` (from `terraform.tfvars.example`) for environment values.

## Commands

```bash
cd infra/terraform/prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform output
```