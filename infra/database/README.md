# Database Setup (PostgreSQL)

Location: `infra/database/`

## Purpose

Database bootstrap assets for local/UAT-like environments and schema reference.

## Init Scripts

- `init-scripts/01-init.sql`
  - creates `customers` table
  - inserts a seed customer row

## Local Compose Integration

`applications/docker-compose.yml` mounts `infra/database/init-scripts` into Postgres init directory.

## Validation

```bash
curl http://localhost:8081/api/customers
```