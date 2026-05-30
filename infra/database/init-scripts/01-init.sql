CREATE TABLE IF NOT EXISTS customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE
);

INSERT INTO customers (name, email)
VALUES ('Enterprise User', 'enterprise.user@example.com')
ON CONFLICT (email) DO NOTHING;