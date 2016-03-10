CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  employee_name VARCHAR(255) UNIQUE,
  employee_email VARCHAR(255) UNIQUE
);
CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  customer_name VARCHAR(255) UNIQUE,
  customer_number VARCHAR(255) UNIQUE
);
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  product_name VARCHAR(255) UNIQUE
);
CREATE TABLE invoice_frequencies (
  id SERIAL PRIMARY KEY,
  invoice_frequency VARCHAR(255) UNIQUE
);
CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  sale_date VARCHAR(255),
  sale_amount VARCHAR(255),
  units_sold INTEGER,
  invoice_number INTEGER,
  product_id INTEGER REFERENCES products (id),
  customer_id INTEGER REFERENCES customers (id),
  employee_id INTEGER REFERENCES employees (id),
  invoice_frequency_id INTEGER REFERENCES invoice_frequencies (id)
);
