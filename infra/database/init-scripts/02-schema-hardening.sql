ALTER TABLE customers
  MODIFY name VARCHAR(100) NOT NULL,
  MODIFY email VARCHAR(150) NOT NULL;

ALTER TABLE orders
  MODIFY product_name VARCHAR(100) NOT NULL,
  MODIFY quantity INT NOT NULL;

ALTER TABLE orders
  ADD CONSTRAINT ck_orders_quantity_positive CHECK (quantity > 0);