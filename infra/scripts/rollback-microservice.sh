#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <namespace> <deployment-name>"
  exit 1
fi

NAMESPACE="$1"
DEPLOYMENT="$2"

kubectl rollout undo deployment/${DEPLOYMENT} -n ${NAMESPACE}
kubectl rollout status deployment/${DEPLOYMENT} -n ${NAMESPACE}

echo "Rollback complete for ${DEPLOYMENT} in ${NAMESPACE}."