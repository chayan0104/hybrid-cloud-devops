# Module: security

Creates security groups for:

- ALB ingress
- WebLogic ingress from ALB on 7001
- EKS internal communication
- MySQL RDS ingress from WebLogic and EKS on 3306

Outputs expose SG IDs for module composition.