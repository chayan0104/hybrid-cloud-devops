# Terraform Bootstrap State

Location: `infra/terraform/bootstrap-state/`

## Purpose

Creates remote Terraform state backend resources:

- S3 bucket for state storage
- DynamoDB table for state locking

## Commands

```bash
cd infra/terraform/bootstrap-state
terraform init
terraform plan
terraform apply
```