# routes/products.py
from flask import Blueprint, jsonify, abort
from config.db import get_db_connection

products_bp = Blueprint('products', __name__)

@products_bp.route('/api/products', methods=['GET'])
def get_products():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT product_id AS id, name, description, price, image_url 
        FROM products
    """)
    products = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify(products)

@products_bp.route('/api/products/<int:product_id>', methods=['GET'])
def get_product_by_id(product_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Find base product name
    cursor.execute("SELECT name FROM products WHERE product_id = %s", (product_id,))
    base = cursor.fetchone()
    if not base:
        return jsonify({"error": "Product not found"}), 404

    # Get all size variants
    cursor.execute("""
        SELECT product_id, name, description, price, size, rating, image_url
        FROM products
        WHERE name = %s
        ORDER BY size
    """, (base["name"],))
    rows = cursor.fetchall()

    cursor.close()
    conn.close()

    product = {
        "id": product_id,
        "name": base["name"],
        "description": rows[0]["description"],
        "rating": rows[0]["rating"],
        "image_url": rows[0]["image_url"],
        "sizes": [
            {"product_id": r["product_id"], "size": r["size"], "price": r["price"]}
            for r in rows
        ]
    }
    return jsonify(product)

@products_bp.route('/api/stock/<int:product_id>', methods=['GET'])
def get_stock(product_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT SUM(quantity_available) AS quantity_available
        FROM warehouse_stock
        WHERE product_id = %s
    """, (product_id,))
    stock = cursor.fetchone()
    
    cursor.close()
    conn.close()
    
    if not stock or stock["quantity_available"] is None:
        return jsonify({"quantity_available": 0})
    return jsonify(stock)

