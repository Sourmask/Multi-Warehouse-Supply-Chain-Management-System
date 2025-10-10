CREATE TABLE IF NOT EXISTS Warehouse (
    warehouse_id INT PRIMARY KEY AUTO_INCREMENT,
    warehouse_name VARCHAR(100) NOT NULL,
    location VARCHAR(150),
    manager_name VARCHAR(100),
    contact_no VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    reorder_level INT DEFAULT 10
);

CREATE TABLE IF NOT EXISTS RetailStore (
    store_id INT PRIMARY KEY AUTO_INCREMENT,
    store_name VARCHAR(100) NOT NULL,
    location VARCHAR(150),
    manager_name VARCHAR(100),
    contact_no VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS Supplier (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    contact_no VARCHAR(15),
    email VARCHAR(100),
    address VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS WarehouseStock (
    stock_id INT PRIMARY KEY AUTO_INCREMENT,
    warehouse_id INT,
    product_id INT,
    quantity INT DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouse(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE IF NOT EXISTS RetailStock (
    rstock_id INT PRIMARY KEY AUTO_INCREMENT,
    store_id INT,
    product_id INT,
    quantity INT DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES RetailStore(store_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE IF NOT EXISTS PurchaseOrder (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id INT,
    warehouse_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouse(warehouse_id)
);

CREATE TABLE IF NOT EXISTS PurchaseOrderDetails (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES PurchaseOrder(order_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE IF NOT EXISTS Dispatch (
    dispatch_id INT PRIMARY KEY AUTO_INCREMENT,
    warehouse_id INT,
    store_id INT,
    dispatch_date DATE,
    status VARCHAR(50) DEFAULT 'In Transit',
    FOREIGN KEY (warehouse_id) REFERENCES Warehouse(warehouse_id),
    FOREIGN KEY (store_id) REFERENCES RetailStore(store_id)
);

CREATE TABLE IF NOT EXISTS DispatchDetails (
    ddetail_id INT PRIMARY KEY AUTO_INCREMENT,
    dispatch_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (dispatch_id) REFERENCES Dispatch(dispatch_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE IF NOT EXISTS Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Admin','WarehouseStaff','RetailManager') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
