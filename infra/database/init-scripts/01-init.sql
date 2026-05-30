CREATE TABLE IF NOT EXISTS customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE
);

INSERT INTO customers (id, name, email)
VALUES
  (1, 'John Doe', 'john.doe@example.com'),
  (2, 'Jane Smith', 'jane.smith@example.com')
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL,
  product_name VARCHAR(100),
  quantity INT,
  CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
);

INSERT INTO orders(customer_id, product_name, quantity)
VALUES
  (1,'Laptop',1),
  (1,'Mouse',2),
  (2,'Keyboard',1)
ON CONFLICT DO NOTHING;