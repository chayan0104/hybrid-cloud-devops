# Terraform Modules

Location: `infra/terraform/modules/`

## Modules

- `network`: VPC, subnets, internet gateway, route tables
- `security`: security groups for ALB, Tomcat, EKS, RDS
- `alb`: ALB + target group + listener
- `tomcat-ec2`: EC2 instance for monolith Tomcat runtime
- `eks`: EKS cluster and node group
- `rds`: PostgreSQL instance and subnet group

These modules are composed in `prod/main.tf` and `perf-prod/main.tf`.