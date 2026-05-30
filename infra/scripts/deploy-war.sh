#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <war-path> <user@host> <tomcat-webapps-dir>"
  exit 1
fi

WAR_PATH="$1"
TARGET_HOST="$2"
TARGET_DIR="$3"

scp "$WAR_PATH" "${TARGET_HOST}:${TARGET_DIR}/"
ssh "$TARGET_HOST" "sudo systemctl restart tomcat"

echo "WAR deployed: ${WAR_PATH} -> ${TARGET_HOST}:${TARGET_DIR}"