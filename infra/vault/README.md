# Vault Secrets Setup

Location: `infra/vault/`

## Files

- `vault-policies.hcl`: Jenkins read policy for shared and environment secret paths
- `vault-secrets-setup.sh`: seed shared/uat/prod/perf-prod secrets
- `VAULT_SETUP.md`: end-to-end setup flow

## Secret Paths

- `secret/shared/*`: JFrog and registry
- `secret/uat/*`: app/db settings
- `secret/prod/*`: app/db settings
- `secret/perf-prod/*`: app/db settings

Pipelines read these at runtime and do not hardcode secrets.