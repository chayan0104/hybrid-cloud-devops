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

vault kv put secret/uat/db host=postgres.uat.internal port=5432 db=app_db user=app_user password=replace_me
vault kv put secret/uat/apps tomcat_host=uat-tomcat.internal microservice_namespace=enterprise-uat

vault kv put secret/prod/db host=prod-rds.aws port=5432 db=app_db user=prod_user password=replace_me
vault kv put secret/prod/apps tomcat_host=prod-tomcat.internal microservice_namespace=enterprise-prod

vault kv put secret/perf-prod/db host=perf-prod-rds.aws port=5432 db=app_db user=perf_user password=replace_me
vault kv put secret/perf-prod/apps tomcat_host=perf-prod-tomcat.internal microservice_namespace=enterprise-perf-prod

echo "Vault secrets seeded for shared, uat, prod, and perf-prod."