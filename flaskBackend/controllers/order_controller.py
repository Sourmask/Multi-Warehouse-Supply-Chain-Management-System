from config.db import get_db_connection

def get_orders():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM orders")
    orders = cursor.fetchall()
    conn.close()
    return orders

def add_order(data):
    conn = get_db_connection()
    cursor = conn.cursor()
    query = "INSERT INTO orders (customer_name, product_name, quantity, warehouse_id) VALUES (%s, %s, %s, %s)"
    values = (data["customer_name"], data["product_name"], data["quantity"], data["warehouse_id"])
    cursor.execute(query, values)
    conn.commit()
    conn.close()
    return {"message": "Order added successfully"}
