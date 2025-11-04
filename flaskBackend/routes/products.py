# routes/products.py
from flask import Blueprint, jsonify
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
