# Database Setup (MySQL)

Location: `infra/database/`

## Purpose

MySQL bootstrap assets for local/UAT-like environments and schema reference.

## Init Scripts

- `init-scripts/01-init.sql`
- `init-scripts/02-schema-hardening.sql`
- `init-scripts/03-indexes-and-views.sql`
- `init-scripts/04-seed-extra-orders.sql`

The scripts create:

- `customers` and `orders` tables
- integrity constraints (quantity > 0)
- indexes for order queries
- `customer_order_summary` view for reporting

## Local Compose Integration

`applications/docker-compose.yml` mounts `infra/database/init-scripts` into the MySQL container's init directory.

## Validation

```bash
curl http://localhost:9093/microservice/api/orders/1
curl http://localhost:9092/monolith/api/customer-summary/1
```