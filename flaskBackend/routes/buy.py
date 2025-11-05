from flask import Blueprint, request, jsonify
from config.db import get_db_connection

buy_bp = Blueprint('buy', __name__)

@buy_bp.route('/api/buy', methods=['POST'])
def buy_product():
    data = request.get_json()
    user_id = data.get("user_id")
    product_id = data.get("product_id")
    size = data.get("size")
    price = data.get("price")

    if not all([user_id, product_id, size, price]):
        return jsonify({"error": "Missing required fields"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Create new order
        cursor.execute("""
            INSERT INTO orders (user_id, total_amount)
            VALUES (%s, %s)
        """, (user_id, price))
        order_id = cursor.lastrowid

        # Add to processing queue (trigger handles assignment + stock)
        cursor.execute("""
            INSERT INTO processing_queue (order_id)
            VALUES (%s)
        """, (order_id,))

        conn.commit()

        return jsonify({
            "message": "Order placed successfully",
            "order_id": order_id
        }), 201

    except Exception as e:
        conn.rollback()
        print("Error while placing order:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        conn.close()
