CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_product_name ON orders(product_name);

CREATE OR REPLACE VIEW customer_order_summary AS
SELECT
  c.id AS customer_id,
  c.name AS customer_name,
  COUNT(o.id) AS total_orders,
  COALESCE(SUM(o.quantity), 0) AS total_items
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY c.id;