# Helm Values

Location: `infra/helm/values/`

Environment-specific overrides:

- `uat-microservice.yaml`
- `prod-microservice.yaml`
- `uat-monolith.yaml`
- `prod-monolith.yaml`

Use with `-f` in Helm deploy commands. The values files mainly vary by:

- image tag and port
- runtime config in `config.env`
- Vault path mapping in `secretProvider.data`
- replica and resource sizing
