CREATE TABLE IF NOT EXISTS customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE
);

INSERT INTO customers (id, name, email)
VALUES
  (1, 'John Doe', 'john.doe@example.com'),
  (2, 'Jane Smith', 'jane.smith@example.com')
ON DUPLICATE KEY UPDATE id = id;

CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  product_name VARCHAR(100) NOT NULL,
  quantity INT NOT NULL,
  CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
);

INSERT INTO orders (customer_id, product_name, quantity)
VALUES
  (1, 'Laptop', 1),
  (1, 'Mouse', 2),
  (2, 'Keyboard', 1)
ON DUPLICATE KEY UPDATE product_name = VALUES(product_name);