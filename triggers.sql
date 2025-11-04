DELIMITER $$

CREATE TRIGGER after_product_insert
AFTER INSERT ON products
FOR EACH ROW
BEGIN
    DECLARE supp_name VARCHAR(100);

    -- Fetch the supplier's name
    SELECT name INTO supp_name FROM suppliers WHERE supplier_id = NEW.supplier_id;

    -- Insert the relationship into supplierlib
    INSERT INTO supplierlib (supplier_id, supplier_name, product_id, product_name)
    VALUES (NEW.supplier_id, supp_name, NEW.product_id, NEW.name);
END$$

DELIMITER ;
