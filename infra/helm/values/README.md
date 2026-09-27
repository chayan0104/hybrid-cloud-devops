# Helm Values

Location: `infra/helm/values/`

Environment-specific overrides:

- `uat-microservice.yaml`
- `prod-microservice.yaml`
- `uat-monolith.yaml`
- `prod-monolith.yaml`

These are optional Helm examples and are not consumed by the Jenkins deployment jobs. Replace the sample JFrog image host and build-number tag before use. The values files mainly vary by:

- image tag and port
- runtime config in `config.env`
- Vault path mapping in `secretProvider.data`
- replica and resource sizing
