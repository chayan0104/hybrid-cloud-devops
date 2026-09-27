#!/usr/bin/env bash
set -euo pipefail

vault kv put secret/shared/jfrog \
  url=https://your-company.jfrog.io \
  docker_repo=docker-local \
  generic_repo=generic-local \
  username=jfrog_user \
  password=replace_me

vault kv put secret/shared/registry \
  url=your-registry.io \
  username=registry_user \
  password=replace_me

vault kv put secret/uat/db db_host=mysql.uat.internal db_port=3306 db_name=app_db db_user=app_user db_password=replace_me
vault kv put secret/uat/apps weblogic_host=uat-weblogic.internal microservice_namespace=enterprise-uat

vault kv put secret/prod/db db_host=prod-mysql.aws db_port=3306 db_name=app_db db_user=app_user db_password=replace_me
vault kv put secret/prod/apps weblogic_host=prod-weblogic.internal microservice_namespace=enterprise-prod

vault kv put secret/perf-prod/db db_host=perf-prod-mysql.aws db_port=3306 db_name=app_db db_user=app_user db_password=replace_me
vault kv put secret/perf-prod/apps weblogic_host=perf-prod-weblogic.internal microservice_namespace=enterprise-perf-prod

echo "Vault secrets seeded for shared, uat, prod, and perf-prod."