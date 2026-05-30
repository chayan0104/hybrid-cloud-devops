#!/usr/bin/env bash
set -euo pipefail

PASS=0
FAIL=0

check_cmd() {
  local cmd="$1"
  local label="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[PASS] ${label} (${cmd})"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] ${label} (${cmd}) not found"
    FAIL=$((FAIL + 1))
  fi
}

check_path() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "[PASS] Path exists: $path"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] Missing path: $path"
    FAIL=$((FAIL + 1))
  fi
}

check_env() {
  local name="$1"
  if [[ -n "${!name:-}" ]]; then
    echo "[PASS] Env set: $name"
    PASS=$((PASS + 1))
  else
    echo "[WARN] Env not set: $name"
  fi
}

check_endpoint() {
  local name="$1"
  local url="$2"
  if [[ -z "$url" ]]; then
    echo "[WARN] Skip endpoint check, not set: $name"
    return
  fi

  if curl -ksS --max-time 8 -o /dev/null "$url"; then
    echo "[PASS] Endpoint reachable: $name -> $url"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] Endpoint unreachable: $name -> $url"
    FAIL=$((FAIL + 1))
  fi
}

echo "== CLI checks =="
check_cmd git "Source control"
check_cmd docker "Container runtime"
check_cmd java "Java runtime"
check_cmd mvn "Maven build"
check_cmd node "Node runtime"
check_cmd npm "NPM package manager"
check_cmd kubectl "Kubernetes client"
check_cmd helm "Helm client"
check_cmd terraform "Terraform client"
check_cmd vault "Vault client"
check_cmd curl "HTTP client"

echo ""
echo "== Dockerized scanner image checks =="
if command -v docker >/dev/null 2>&1; then
  docker run --rm aquasec/trivy:0.56.2 --version >/dev/null 2>&1 && echo "[PASS] Trivy image" && PASS=$((PASS + 1)) || { echo "[FAIL] Trivy image"; FAIL=$((FAIL + 1)); }
  docker run --rm aquasec/tfsec:v1.28.5 --version >/dev/null 2>&1 && echo "[PASS] tfsec image" && PASS=$((PASS + 1)) || { echo "[FAIL] tfsec image"; FAIL=$((FAIL + 1)); }
  docker run --rm bridgecrew/checkov:3.2.360 --version >/dev/null 2>&1 && echo "[PASS] checkov image" && PASS=$((PASS + 1)) || { echo "[FAIL] checkov image"; FAIL=$((FAIL + 1)); }
  docker run --rm zricethezav/gitleaks:v8.21.2 version >/dev/null 2>&1 && echo "[PASS] gitleaks image" && PASS=$((PASS + 1)) || { echo "[FAIL] gitleaks image"; FAIL=$((FAIL + 1)); }
else
  echo "[WARN] Docker not available, scanner image checks skipped"
fi

echo ""
echo "== Repository path checks =="
check_path "infra/jenkins/Jenkinsfile-CI"
check_path "infra/jenkins/Jenkinsfile-UAT"
check_path "infra/jenkins/Jenkinsfile-PROD"
check_path "infra/kubernetes/uat"
check_path "infra/kubernetes/prod"
check_path "infra/terraform/prod"
check_path "infra/terraform/perf-prod"
check_path "infra/vault/vault-secrets-setup.sh"
check_path "infra/scripts/TOOLING-READINESS-MATRIX.md"

echo ""
echo "== Environment variable checks =="
check_env VAULT_ADDR
check_env SONAR_HOST_URL

echo ""
if [[ "${STRICT_ENDPOINT_CHECKS:-false}" == "true" ]]; then
  echo "== Endpoint checks (strict) =="
  check_endpoint "Vault" "${VAULT_ADDR:-}"
  check_endpoint "SonarQube" "${SONAR_HOST_URL:-}"
else
  echo "== Endpoint checks =="
  echo "[INFO] Strict endpoint checks disabled. Set STRICT_ENDPOINT_CHECKS=true to enable."
fi

echo ""
echo "Preflight summary: PASS=${PASS} FAIL=${FAIL}"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi

exit 0