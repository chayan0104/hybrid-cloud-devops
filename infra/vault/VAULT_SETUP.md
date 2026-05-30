# Vault Setup

## Initialize

```bash
vault operator init
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>
vault login <root-token>
```

## Configure Jenkins AppRole

```bash
vault policy write jenkins-policy infra/vault/vault-policies.hcl
vault auth enable approle
vault write auth/approle/role/jenkins-role token_policies="jenkins-policy"
vault read auth/approle/role/jenkins-role/role-id
vault write -f auth/approle/role/jenkins-role/secret-id
```

## Seed Secret Paths

```bash
bash infra/vault/vault-secrets-setup.sh
```

Seeded paths include:

- `secret/shared/*` for JFrog and registry credentials
- `secret/uat/*` for UAT app and database settings
- `secret/prod/*` for PROD app and database settings
- `secret/perf-prod/*` for perf-prod app and database settings

Pipelines use Vault at runtime for all environments and do not hardcode DB or artifact credentials.