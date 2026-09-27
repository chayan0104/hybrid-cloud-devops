# Database Init Scripts

Location: `infra/database/init-scripts/`

`01-init.sql` is executed by MySQL container initialization in local Compose and by the optional `infra/k8s/` lab after its init ConfigMap is created.

It creates seed schema objects and inserts bootstrap data for application verification.

Execution order:

- `01-init.sql`: base tables and core seed data
- `02-schema-hardening.sql`: not-null and check constraints
- `03-indexes-and-views.sql`: query indexes and reporting view
- `04-seed-extra-orders.sql`: additional sample orders

After changing scripts, recreate DB volume for local compose to re-run init:

```bash
cd applications
docker compose down -v
docker compose up -d --build
```