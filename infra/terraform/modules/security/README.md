# Module: security

Creates security groups for:

- ALB ingress
- WebLogic ingress from ALB on 7001
- EKS internal communication
- RDS ingress from WebLogic and EKS on 5432

Outputs expose SG IDs for module composition.