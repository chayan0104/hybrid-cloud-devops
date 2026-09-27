# Environment-Specific Kubernetes Manifests

Location: `infra/kubernetes/`

These manifests are the input to the UAT/PROD Jenkins deployment jobs. They contain image and environment placeholders and should not be applied unchanged.

## Environments

- `uat/`: frontend, monolith, and microservice in namespace `enterprise-uat`; intended for a UAT Kubernetes cluster such as kind.
- `prod/`: frontend and microservice in namespace `enterprise-prod`; Jenkins does not apply the monolith manifests because PROD keeps the WAR on WebLogic/EC2. Canary/blue-green examples are not automated by the pipeline.
- `perf-prod/`: frontend and microservice references in namespace `enterprise-perf-prod`; no Jenkins pipeline currently targets this folder.

Backend manifests consume MySQL connection settings from Kubernetes Secrets. UAT and PROD Jenkins jobs render the secret values from their Jenkins credential bindings. Vault is not currently connected to these jobs.

## Pipeline Use

- UAT job: `infra/jenkins/Jenkinsfile-UAT`
- PROD job: `infra/jenkins/Jenkinsfile-PROD`

Both jobs require an immutable `IMAGE_TAG` published by CI and a Kubernetes context for the correct environment. PROD also requires the WebLogic ALB upstream used by the frontend proxy.

## Validation

The repository includes no active cluster context by default. Before deployment, inspect the rendered manifests and use a cluster with the required namespace permissions, registry pull secret, MySQL connectivity, and policy configuration. Do not use a raw directory apply while image placeholders remain unresolved.