CREATE DATABASE amazon_ecosystem;
USE amazon_ecosystem;
-- 1. Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50),
    signup_date DATE,
    segment VARCHAR(50)  -- e.g. Premium, Regular, New
);

-- 2. Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150),
    category VARCHAR(100),
    sub_category VARCHAR(100),
    price DECIMAL(10,2),
    rating DECIMAL(3,1)
);

-- 3. Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    status VARCHAR(50),  -- Delivered, Returned, Cancelled
    payment_method VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 4. Order Items Table
CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(5,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 5. Inventory Table
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    stock_quantity INT,
    reorder_level INT,
    last_restocked DATE,
    warehouse_location VARCHAR(100),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Customers
INSERT INTO customers VALUES
(1, 'Rahul Sharma', 'rahul@gmail.com', 'Mumbai', 'India', '2022-01-15', 'Premium'),
(2, 'Priya Singh', 'priya@gmail.com', 'Delhi', 'India', '2022-03-10', 'Regular'),
(3, 'Arun Kumar', 'arun@gmail.com', 'Chennai', 'India', '2023-06-01', 'New'),
(4, 'Sneha Patel', 'sneha@gmail.com', 'Ahmedabad', 'India', '2021-11-20', 'Premium'),
(5, 'Vikram Nair', 'vikram@gmail.com', 'Bangalore', 'India', '2023-01-05', 'Regular');

-- Products
INSERT INTO products VALUES
(1, 'iPhone 15', 'Electronics', 'Smartphones', 79999.00, 4.7),
(2, 'Samsung TV 55"', 'Electronics', 'Televisions', 55000.00, 4.5),
(3, 'Nike Running Shoes', 'Fashion', 'Footwear', 4999.00, 4.3),
(4, 'Instant Pot', 'Kitchen', 'Appliances', 6999.00, 4.6),
(5, 'Harry Potter Set', 'Books', 'Fiction', 1999.00, 4.8);

-- Orders
INSERT INTO orders VALUES
(1, 1, '2024-01-10', 'Delivered', 'Credit Card'),
(2, 2, '2024-01-15', 'Delivered', 'UPI'),
(3, 3, '2024-02-01', 'Cancelled', 'Debit Card'),
(4, 4, '2024-02-20', 'Delivered', 'Credit Card'),
(5, 5, '2024-03-05', 'Returned', 'UPI'),
(6, 1, '2024-03-15', 'Delivered', 'Credit Card'),
(7, 2, '2024-04-01', 'Delivered', 'UPI');

-- Order Items
INSERT INTO order_items VALUES
(1, 1, 1, 1, 79999.00, 5.00),
(2, 2, 3, 2, 4999.00, 0.00),
(3, 3, 2, 1, 55000.00, 10.00),
(4, 4, 4, 1, 6999.00, 0.00),
(5, 5, 5, 3, 1999.00, 0.00),
(6, 6, 2, 1, 55000.00, 5.00),
(7, 7, 1, 1, 79999.00, 0.00);

-- Inventory
INSERT INTO inventory VALUES
(1, 1, 50, 20, '2024-01-01', 'Mumbai Warehouse'),
(2, 2, 30, 10, '2024-01-15', 'Delhi Warehouse'),
(3, 3, 150, 50, '2024-02-01', 'Chennai Warehouse'),
(4, 4, 75, 25, '2024-02-10', 'Bangalore Warehouse'),
(5, 5, 200, 100, '2024-03-01', 'Mumbai Warehouse');

SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM inventory;

SELECT 
    p.category,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(oi.quantity * oi.unit_price) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY month
ORDER BY month;

SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

SELECT 
    c.customer_name,
    c.city,
    c.segment,
    COUNT(o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_name, c.city, c.segment
ORDER BY total_spent DESC;

SELECT 
    payment_method,
    COUNT(*) AS usage_count
FROM orders
GROUP BY payment_method
ORDER BY usage_count DESC;

SELECT 
    status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / 
    (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY status;

SELECT 
    p.product_name,
    i.stock_quantity,
    i.reorder_level,
    i.warehouse_location,
    CASE 
        WHEN i.stock_quantity <= i.reorder_level 
        THEN 'Reorder Needed'
        ELSE 'Stock OK'
    END AS stock_status
FROM inventory i
JOIN products p ON i.product_id = p.product_id;

SELECT 
    c.city,
    SUM(oi.quantity * oi.unit_price) AS city_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.city
ORDER BY city_revenue DESC;

SELECT SUM(quantity * unit_price) AS total_revenue FROM order_items;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_customers FROM customers;

SELECT 
    c.customer_name,
    c.city,
    c.segment,
    p.category,
    p.product_name,
    o.order_date,
    o.status AS order_status,
    o.payment_method,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS revenue,
    i.stock_quantity,
    i.reorder_level,
    CASE 
        WHEN i.stock_quantity <= i.reorder_level 
        THEN 'Reorder Needed'
        ELSE 'Stock OK'
    END AS stock_status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN inventory i ON p.product_id = i.product_id;