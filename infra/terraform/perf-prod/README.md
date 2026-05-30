# Terraform PERF-PROD Environment

Location: `infra/terraform/perf-prod/`

## Purpose

Provision a PROD-like environment for performance and rollout validation.

## Topology

Same module composition as PROD with separate CIDR and naming prefix.

## Commands

```bash
cd infra/terraform/perf-prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform output
```