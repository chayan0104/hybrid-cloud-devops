# Vault Secrets Setup

Location: `infra/vault/`

## Files

- `vault-policies.hcl`: read policy examples for shared and environment secret paths
- `vault-secrets-setup.sh`: seed shared/uat/prod/perf-prod secrets
- `VAULT_SETUP.md`: end-to-end setup flow

## Secret Paths

- `secret/shared/*`: JFrog and registry
- `secret/uat/*`: app/db settings
- `secret/prod/*`: app/db settings
- `secret/perf-prod/*`: app/db settings

The Jenkins pipelines currently use Jenkins credential bindings and do not read these Vault paths. Treat the scripts and policy as optional integration examples until Vault authentication and retrieval are wired into and tested by the jobs.