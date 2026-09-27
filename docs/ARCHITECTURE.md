# Architecture and Implementation Status

## System overview

This project models a hybrid cloud application delivery pattern built around a small but realistic application topology:

- Angular frontend for the user-facing experience
- Java monolith packaged as a WAR for legacy-style deployment
- Spring Boot microservice for API and service-layer responsibilities
- MySQL as the shared persistence layer
- Kubernetes and AWS infrastructure to represent cloud-native deployment patterns

The application is intentionally structured to show how a modern DevOps workflow can manage a mixed technology stack without requiring a single, fully homogeneous runtime model.

## Request flow

The frontend app does not call backend services directly through host-specific URLs. Instead, it uses same-origin routes that are proxied by Nginx:

- `/monolith/...` routes to the Java monolith
- `/microservice/...` routes to the Spring Boot service

This pattern helps keep the front-end environment portable and simplifies configuration across local, UAT, and cloud-based runtime setups.

## Runtime composition

### Local environment

The Compose setup runs the following services together:

- Frontend Angular application
- Java monolith container
- Spring Boot microservice
- MySQL database

Local ports are configured as:

- Frontend: `9091`
- Monolith: `9092`
- Microservice: `9093`

The backend APIs are purposefully exposed through the frontend proxy layer rather than by telling the browser to call backend ports directly.

### UAT and PROD

| Environment | Runtime model | Database | Status |
|---|---|---|---|
| Local | Docker Compose | MySQL container | Implemented and validated locally |
| UAT | Kubernetes namespace `enterprise-uat` | External MySQL | Jenkins-driven deployment flow |
| PROD | EKS for frontend and microservice; WebLogic/EC2 for monolith | MySQL RDS | Partial automation |
| PERF-PROD | Environment-specific Terraform + Kubernetes configuration | MySQL RDS target | Reference configuration |

## Delivery pipeline

The repository demonstrates a multi-stage delivery flow:

1. `infra/jenkins/Jenkinsfile-CI` builds both application artifacts and the frontend bundle, runs configured checks, tags the image with the Jenkins build number, and publishes to JFrog.
2. `infra/jenkins/Jenkinsfile-UAT` applies environment manifests to Kubernetes and validates application health.
3. `infra/jenkins/Jenkinsfile-PROD` rolls out the frontend and microservice to EKS and validates service health.
4. The monolith WAR is archived by CI and deployed separately through the existing manual script workflow.

This arrangement is realistic for a hybrid environment where a legacy Java application cannot be fully absorbed into the same deployment path as a Kubernetes-native microservice.

## Infrastructure as code

The Terraform layer defines reusable components for:

- networking and VPC structure
- security groups
- ALB and WebLogic hosting infrastructure
- EKS cluster resources
- RDS MySQL provisioning

The modules under `infra/terraform/modules/` are intended to show modular infrastructure design. Environment files in `infra/terraform/prod/` and `infra/terraform/perf-prod/` compose those modules into deployable stacks.

## Current implementation boundaries

A few boundaries are intentionally left documented rather than hidden:

- `infra/kubernetes/` contains the active environment manifests, while `infra/k8s/` remains a separate lab/reference bundle.
- The frontend EKS ingress path is not fully defined in the repository.
- WebLogic WAR deployment is manual and requires a separate runtime procedure.
- Some vulnerability scan stages are reporting-only and do not fail builds.
- Vault integration is present as a setup pattern, but not yet fully wired into Jenkins authentication flows.

## Design summary

This repository is best understood as a realistic DevOps portfolio project: it demonstrates practical cross-domain thinking, not a production-certified enterprise platform. The value is in the architectural intent, operational discipline, and ability to explain the trade-offs between cloud-native, containerized, and legacy deployment strategies.
