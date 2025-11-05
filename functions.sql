DELIMITER //

CREATE PROCEDURE create_user(
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),
    IN p_phone VARCHAR(15),
    IN p_pincode CHAR(6)
)
BEGIN
    INSERT INTO users (name, email, password, phone, pincode)
    VALUES (p_name, p_email, p_password, p_phone, p_pincode);
END //


CREATE PROCEDURE create_supplier(
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(15),
    IN p_address_pincode CHAR(6)
)
BEGIN
    INSERT INTO suppliers (name, email, phone, address_pincode)
    VALUES (p_name, p_email, p_phone, p_address_pincode);
END //


CREATE PROCEDURE add_employee(
    IN p_name VARCHAR(100),
    IN p_role ENUM('Stocker','Packer','Delivery'),
    IN p_warehouse_id INT
)
BEGIN
    INSERT INTO employees (name, role, warehouse_id)
    VALUES (p_name, p_role, p_warehouse_id);
END //


CREATE PROCEDURE create_product(
    IN p_name VARCHAR(100),
    IN p_desc TEXT,
    IN p_price DECIMAL(10,2),
    IN p_size VARCHAR(20),
    IN p_supplier_id INT,
    IN p_image_url VARCHAR(255)
)
BEGIN
    INSERT INTO products (name, description, price, size, supplier_id, image_url)
    VALUES (p_name, p_desc, p_price, p_size, p_supplier_id, p_image_url);
END //


CREATE PROCEDURE update_stock(
    IN p_warehouse_id INT,
    IN p_product_id INT,
    IN p_qty_change INT
)
BEGIN
    UPDATE warehouse_stock
    SET quantity_available = quantity_available + p_qty_change
    WHERE warehouse_id = p_warehouse_id AND product_id = p_product_id;
END //


DELIMITER ;
