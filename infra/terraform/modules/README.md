# Terraform Modules

Location: `infra/terraform/modules/`

## Modules

- `network`: VPC, subnets, internet gateway, route tables
- `security`: security groups for ALB, WebLogic, EKS, RDS
- `alb`: ALB + target group + listener
- `weblogic-ec2`: EC2 instance for monolith WebLogic runtime
- `eks`: EKS cluster and node group
- `rds`: MySQL instance and subnet group

These modules are composed in `prod/main.tf` and `perf-prod/main.tf`.