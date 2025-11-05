DELIMITER $$

DROP TRIGGER IF EXISTS after_product_insert
CREATE TRIGGER after_product_insert
AFTER INSERT ON products
FOR EACH ROW
BEGIN
    DECLARE supp_name VARCHAR(100);

    SELECT name INTO supp_name 
    FROM suppliers 
    WHERE supplier_id = NEW.supplier_id;

    INSERT INTO supplierlib (supplier_id, supplier_name, product_id, product_name)
    VALUES (NEW.supplier_id, supp_name, NEW.product_id, NEW.name);
END$$

DROP TRIGGER IF EXISTS after_processing_queue_insert$$
CREATE TRIGGER after_processing_queue_insert
AFTER INSERT ON processing_queue
FOR EACH ROW
BEGIN
    DECLARE v_user_pincode CHAR(6);
    DECLARE v_closest_warehouse INT DEFAULT NULL;
    DECLARE v_min_diff INT DEFAULT 999999;
    DECLARE v_temp_diff INT;
    DECLARE v_wh_id INT;
    DECLARE v_wh_pincode CHAR(6);
    DECLARE done INT DEFAULT 0;

    DECLARE wh_cursor CURSOR FOR
        SELECT warehouse_id, location_pincode FROM warehouses;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    SELECT u.pincode
    INTO v_user_pincode
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    WHERE o.order_id = NEW.order_id
    LIMIT 1;

    OPEN wh_cursor;
    read_loop: LOOP
        FETCH wh_cursor INTO v_wh_id, v_wh_pincode;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET v_temp_diff = ABS(CAST(v_user_pincode AS SIGNED) - CAST(v_wh_pincode AS SIGNED));

        IF v_temp_diff < v_min_diff THEN
            SET v_min_diff = v_temp_diff;
            SET v_closest_warehouse = v_wh_id;
        END IF;
    END LOOP;
    CLOSE wh_cursor;

    IF v_closest_warehouse IS NOT NULL THEN
        INSERT INTO warehouse_queue (order_id, warehouse_id, assigned_time, notes)
        VALUES (NEW.order_id, v_closest_warehouse, NOW(), 'Auto-assigned');

        INSERT INTO order_status (order_id, status, changed_by)
        VALUES (NEW.order_id, 'Processing', 'trigger');
    ELSE
        INSERT INTO order_status (order_id, status, changed_by)
        VALUES (NEW.order_id, 'Waiting', 'trigger');
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_stocker_take_job$$
CREATE TRIGGER trg_stocker_take_job
AFTER UPDATE ON warehouse_queue
FOR EACH ROW
BEGIN
    IF OLD.assigned_employee IS NULL AND NEW.assigned_employee IS NOT NULL THEN
        INSERT INTO stocker_activity (employee_id, wq_id, action)
        VALUES (NEW.assigned_employee, NEW.wq_id, 'Taken');
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_stocker_complete_job$$
CREATE TRIGGER trg_stocker_complete_job
AFTER INSERT ON packing_queue
FOR EACH ROW
BEGIN
    INSERT INTO stocker_activity (employee_id, wq_id, action)
    VALUES (NEW.assigned_employee, NEW.warehouse_id, 'Completed');
END$$

DROP TRIGGER IF EXISTS trg_packer_take_job$$
CREATE TRIGGER trg_packer_take_job
AFTER UPDATE ON packing_queue
FOR EACH ROW
BEGIN
    IF OLD.assigned_employee IS NULL AND NEW.assigned_employee IS NOT NULL THEN
        INSERT INTO packer_activity (employee_id, pq_id, action)
        VALUES (NEW.assigned_employee, NEW.pq_id, 'Taken');
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_packer_complete_job$$
CREATE TRIGGER trg_packer_complete_job
AFTER INSERT ON delivery
FOR EACH ROW
BEGIN
    INSERT INTO packer_activity (employee_id, pq_id, action)
    VALUES (NEW.employee_id, NEW.order_id, 'Completed');
END$$

DELIMITER ;
