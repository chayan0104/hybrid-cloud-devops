# Module: security

Creates security groups for:

- ALB ingress
- Tomcat ingress from ALB
- EKS internal communication
- RDS ingress from Tomcat and EKS on 5432

Outputs expose SG IDs for module composition.