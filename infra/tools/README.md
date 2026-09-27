# Tooling and Prerequisites

This directory currently contains this index only; setup scripts referenced by older versions of this guide are not checked in.

## Local Application

- Docker Engine or Docker Desktop with Compose
- Node.js/npm for frontend development
- Java 25 and Maven for the Java projects

Start the local stack with `docker compose -f applications/docker-compose.yml up -d --build` from the repository root. See the [setup guide](../../docs/SETUP-AND-DEPLOYMENT-GUIDE.md).

## Infrastructure and Delivery

- Terraform and AWS credentials for infrastructure planning/provisioning
- `kubectl` and an environment-specific Kubernetes context for UAT/PROD deployment
- Helm only for the optional chart path
- Jenkins, Docker, JFrog settings, and credentials for the checked-in pipelines

See the [infrastructure guide](../../docs/INFRASTRUCTURE.md), [Jenkins guide](../jenkins/README.md), [Terraform guide](../terraform/README.md), and [Kubernetes guide](../kubernetes/README.md).

## Security and Monitoring Examples

Security scanners are invoked by the CI pipeline. Vault, monitoring, and Helm assets are examples that require their external services/operators to be configured; they are not fully bootstrapped by this directory.

See [Vault setup](../vault/README.md), [monitoring assets](../monitoring/README.md), and the [verified backlog](../../docs/todo.md).