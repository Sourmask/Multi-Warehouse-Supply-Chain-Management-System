-- ===================================================
-- Multi-Warehouse Supply Chain Management System
-- ===================================================

CREATE DATABASE IF NOT EXISTS supply_chain_db;
USE supply_chain_db;

-- ===================================================
-- USERS TABLE
-- ===================================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    pincode CHAR(6) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===================================================
-- SUPPLIERS TABLE
-- ===================================================
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    address_pincode CHAR(6) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE supplierlib (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    supplier_name VARCHAR(100) NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ===================================================
-- WAREHOUSES TABLE
-- ===================================================
CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location_pincode CHAR(6) NOT NULL,
    capacity INT DEFAULT 0
);

-- ===================================================
-- PRODUCTS TABLE
-- ===================================================
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    size VARCHAR(20),
    rating DECIMAL(2,1) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    supplier_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- ===================================================
-- WAREHOUSE STOCK TABLE
-- ===================================================
CREATE TABLE warehouse_stock (
    stock_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity_available INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ===================================================
-- ORDERS TABLE
-- ===================================================
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Processing','Packed','Dispatched','Delivered','Cancelled') DEFAULT 'Processing',
    total_amount DECIMAL(10,2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ===================================================
-- ORDER ITEMS TABLE
-- ===================================================
CREATE TABLE order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ===================================================
-- ORDER STATUS HISTORY TABLE
-- ===================================================
CREATE TABLE order_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status ENUM('Processing','Packed','Dispatched','Delivered','Cancelled') NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100) DEFAULT 'system',
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ===================================================
-- PROCESSING QUEUE TABLE
-- ===================================================
CREATE TABLE processing_queue (
    queue_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status ENUM('Pending','Assigned','In_Progress','Completed') DEFAULT 'Pending',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ===================================================
-- EMPLOYEES TABLE
-- ===================================================
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role ENUM('Stocker','Packer','Delivery') NOT NULL,
    warehouse_id INT,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

-- ===================================================
-- WAREHOUSE QUEUE TABLE
-- ===================================================
CREATE TABLE warehouse_queue (
    wq_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    assigned_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Waiting','Picking','Packing','Dispatched','Completed') DEFAULT 'Waiting',
    assigned_employee INT,
    notes TEXT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (assigned_employee) REFERENCES employees(employee_id)
);

-- ===================================================
-- WAREHOUSE QUEUE ITEMS TABLE
-- ===================================================
CREATE TABLE warehouse_queue_items (
    wqi_id INT AUTO_INCREMENT PRIMARY KEY,
    wq_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    status ENUM('Pending','Picked','Packed','Shipped') DEFAULT 'Pending',
    FOREIGN KEY (wq_id) REFERENCES warehouse_queue(wq_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ===================================================
-- DELIVERY TABLE
-- ===================================================
CREATE TABLE delivery (
    delivery_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    employee_id INT,
    status ENUM('Out_for_Delivery','Delivered','Returned') DEFAULT 'Out_for_Delivery',
    dispatched_at DATETIME,
    delivered_at DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);


ALTER TABLE products ADD COLUMN image_url VARCHAR(255);