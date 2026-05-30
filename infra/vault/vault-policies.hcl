path "secret/data/uat/*" {
  capabilities = ["read"]
}

path "secret/data/prod/*" {
  capabilities = ["read"]
}

path "secret/data/perf-prod/*" {
  capabilities = ["read"]
}

path "secret/data/shared/*" {
  capabilities = ["read"]
}

path "auth/approle/login" {
  capabilities = ["create", "read"]
}