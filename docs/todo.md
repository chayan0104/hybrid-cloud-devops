# Verified Backlog

Items are based on the checked-in implementation, not aspirational feature claims.

## Release Blockers

- Add and validate public ingress/load-balancer routing to the PROD EKS frontend; Terraform currently wires the ALB to WebLogic only.
- Decide and implement a secure Terraform remote backend with encryption, locking, access control, and recovery procedures.
- Validate the WebLogic WAR helper against the actual server/service layout; then decide whether Jenkins should automate this step.
- Confirm EKS-to-MySQL-RDS networking and application credential rotation in a representative environment.
- Validate the converted single-pod MySQL lab against a disposable cluster, including schema initialization and NetworkPolicy connectivity; use managed RDS for shared environments.

## Pipeline Hardening

- Make approved scan thresholds blocking; several current scans are report-only.
- Add a tested smoke/integration test stage for the customer-summary flow and database-backed order endpoints.
- Ensure deploy jobs can only promote artifacts produced by the approved CI run and environment; validate JFrog permissions and image retention.
- Review secret rendering/workspace cleanup and replace temporary Kubernetes Secret YAML with the chosen production secret integration.
- Add deployment health checks for the full frontend-to-monolith-to-microservice route.

## Infrastructure and Operations

- Enable RDS encryption, backups/retention, deletion protection, and production-appropriate availability after requirements and budget approval.
- Add deployment validation for the EKS frontend ingress and the WebLogic ALB health check.
- Review IAM roles, security groups, Pod Security Standards, NetworkPolicies, and least-privilege service accounts across the environment-specific manifests.
- Define tested database backup/restore, disaster recovery, and rollback procedures.
- Pin/refresh base images and dependencies through a documented update cadence; generate SBOM/provenance if required by the target role.

## Portfolio Polish

- Add evidence from an actual successful local Compose run and, if available, a disposable Kubernetes/AWS deployment.
- Include pipeline screenshots or sanitized reports only after a real run; do not invent performance or availability metrics.
- Tailor the summary and interview examples to the resume once it is available.