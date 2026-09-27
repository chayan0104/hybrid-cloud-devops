# Jenkins CI/CD Setup

## Pipelines

- `Jenkinsfile-CI`: builds Angular, the monolith WAR/container, and the microservice; runs scans; publishes container images to JFrog.
- `Jenkinsfile-UAT`: deploys frontend, monolith, and microservice to `enterprise-uat` using `infra/kubernetes/uat/`.
- `Jenkinsfile-PROD`: deploys frontend and microservice to `enterprise-prod` using `infra/kubernetes/prod/`; the monolith WAR remains a separate manual WebLogic deployment.

## Jenkins Configuration

Global environment values:

- `JFROG_SERVER`: registry hostname only, without `http://` or `https://`
- `JFROG_DOCKER_REPO`: JFrog Docker repository key
- `DEVOPS_NOTIFY_EMAIL`: notification recipient for pipeline reports
- `SONAR_HOST_URL`: SonarQube URL reachable from the CI agent when code scans are enabled

Credentials:

- `jfrog-creds`: username/password with push and pull access to the Docker repository
- `uat-mysql-credentials`: UAT MySQL username/password
- `prod-mysql-credentials`: production MySQL username/password
- `sonarqube-token`: SonarQube token

The `vault-approle` credential is not consumed by these pipelines. Vault policies/setup are examples only; do not describe the current pipeline as retrieving secrets from Vault.

Install Jenkins Pipeline, Git, Credentials Binding, and Email Extension plugins. Configure SMTP for `emailext`.

Linux agents require Docker, Java/JDK 25, Maven, Node.js/npm, `kubectl`, `curl`, `base64`, and `mktemp`. CI invokes Trivy, tfsec, Checkov, and Gitleaks as Docker containers. Deployment agents also need a configured Kubernetes context with namespace permissions.

## Job Inputs

CI produces images tagged with the Jenkins build number. Deploy that exact build number as `IMAGE_TAG`.

UAT job inputs:

- `IMAGE_TAG`, `DB_HOST`, `DB_PORT` (3306), and `DB_NAME` (default `app_db`)
- A cluster/context that targets the UAT cluster

PROD job inputs:

- `IMAGE_TAG`, `DB_HOST` (RDS endpoint), `DB_PORT` (3306), and `DB_NAME` (`app_db`)
- `MONOLITH_UPSTREAM`: WebLogic ALB URL including scheme; the frontend Nginx proxy uses it for `/monolith/`
- A cluster/context that targets EKS

Deployment jobs create a namespace-scoped `jfrog-registry` pull secret and render temporary application Secret YAML. The latter uses shell substitution; avoid passwords containing the substitution delimiter and use isolated, ephemeral agents where possible.

## Pipeline Behavior and Limits

- CI archives the monolith WAR in Jenkins; it does not publish the WAR to a JFrog generic repository.
- PROD validates EKS rollouts and the microservice actuator health endpoint. It does not deploy or validate the WebLogic WAR.
- UAT/PROD rollback performs Kubernetes revision rollback for deployed workloads; it does not roll back database schema or WebLogic releases.
- Several security scans are report-only (`|| true` or Trivy `--exit-code 0`) and do not currently block a release.
- The repository does not define a public EKS ingress for the frontend.

See [the deployment guide](../../docs/SETUP-AND-DEPLOYMENT-GUIDE.md) for environment setup and [the interview guide](../../docs/INTERVIEW.md) for an accurate project walkthrough.