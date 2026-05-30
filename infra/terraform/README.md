# Terraform Reusable Infra Model

This Terraform layout is reusable across environments by composing small modules.

## Modules

- `modules/network`: VPC, public/private subnets, internet gateway, route table
- `modules/security`: security groups for ALB, Tomcat, EKS, and RDS
- `modules/tomcat-ec2`: EC2 instance for Tomcat-hosted WAR applications
- `modules/alb`: public ALB and target-group wiring to Tomcat
- `modules/eks`: EKS control plane and node group for microservices
- `modules/rds`: PostgreSQL instance and subnet group

## Environment architecture

- UAT: external/shared Tomcat host + Kubernetes cluster
- PROD: EC2 Tomcat + EKS + RDS behind ALB
- PERF-PROD: same as PROD using separate CIDR and environment prefix

`prod/main.tf` and `perf-prod/main.tf` compose these modules with environment inputs.

## Network connectivity

- Main-app WAR runs in Tomcat on EC2 in private subnet.
- Frontend and microservice run in EKS private subnets.
- PostgreSQL (RDS) runs in private subnets.
- Security groups allow Tomcat and EKS to connect to PostgreSQL on 5432.