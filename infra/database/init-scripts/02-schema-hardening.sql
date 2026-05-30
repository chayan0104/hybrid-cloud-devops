ALTER TABLE customers
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN email SET NOT NULL;

ALTER TABLE orders
  ALTER COLUMN product_name SET NOT NULL,
  ALTER COLUMN quantity SET NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'ck_orders_quantity_positive'
  ) THEN
    ALTER TABLE orders
      ADD CONSTRAINT ck_orders_quantity_positive CHECK (quantity > 0);
  END IF;
END
$$;