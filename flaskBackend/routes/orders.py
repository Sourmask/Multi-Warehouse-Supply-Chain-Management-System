from flask import Blueprint, request, jsonify
from controllers.order_controller import get_orders, add_order

orders_bp = Blueprint('orders', __name__)

@orders_bp.route('/api/orders', methods=['GET'])
def fetch_orders():
    orders = get_orders()
    return jsonify(orders)

@orders_bp.route('/api/orders', methods=['POST'])
def create_order():
    data = request.get_json()
    result = add_order(data)
    return jsonify(result)
