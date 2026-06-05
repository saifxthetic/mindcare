CREATE DATABASE IF NOT EXISTS mindcare_db;
USE mindcare_db;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE, -- UNIQUE already acts as index for login
  password VARCHAR(255) NOT NULL
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  description TEXT NOT NULL,
  category ENUM('Meditation','Therapy','Journal','Course','Ebook','Audio') NOT NULL DEFAULT 'Meditation',
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  image_url VARCHAR(255) DEFAULT '',
  is_digital TINYINT(1) DEFAULT 1,
  is_active TINYINT(1) DEFAULT 1,

  -- Filter by category (Meditation, Therapy etc)
  INDEX idx_products_category (category),

  -- Filter active/inactive products
  INDEX idx_products_is_active (is_active),

  -- Filter by price range
  INDEX idx_products_price (price),

  -- Most common: active products by category
  INDEX idx_products_category_active (category, is_active)
);

-- Wishlist table
CREATE TABLE IF NOT EXISTS wishlist (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  UNIQUE KEY unique_user_product (user_id, product_id), -- already acts as index
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,

  -- Fetch all wishlist items for a user
  INDEX idx_wishlist_user_id (user_id),

  -- Fetch all users who wishlisted a product
  INDEX idx_wishlist_product_id (product_id)
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  status ENUM('Pending','Paid','Cancelled') DEFAULT 'Pending',
  payment_method VARCHAR(50) DEFAULT 'Demo Payment',
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

  -- Fetch all orders for a user
  INDEX idx_orders_user_id (user_id),

  -- Filter orders by status
  INDEX idx_orders_status (status),

  -- Most common: user orders by status
  INDEX idx_orders_user_status (user_id, status)
);

-- Order Items table
CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,

  -- Fetch all items in an order
  INDEX idx_order_items_order_id (order_id),

  -- Fetch all orders containing a product
  INDEX idx_order_items_product_id (product_id)
);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_status ENUM('Pending','Success','Failed') DEFAULT 'Pending',
  transaction_ref VARCHAR(100) DEFAULT '',
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,

  -- Fetch payment for an order
  INDEX idx_payments_order_id (order_id),

  -- Filter by payment status
  INDEX idx_payments_status (payment_status),

  -- Lookup by transaction reference
  INDEX idx_payments_transaction_ref (transaction_ref)
);