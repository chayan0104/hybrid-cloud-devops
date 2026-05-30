INSERT INTO orders (id, customer_id, product_name, quantity)
VALUES
  (4, 1, 'Monitor', 1),
  (5, 2, 'USB Hub', 1),
  (6, 2, 'Headset', 2)
ON CONFLICT (id) DO NOTHING;