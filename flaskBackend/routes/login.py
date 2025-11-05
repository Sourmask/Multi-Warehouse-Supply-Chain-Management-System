from flask import Blueprint, request, jsonify
from config.db import get_db_connection

login_bp = Blueprint("login", __name__)

@login_bp.route("/user", methods=["POST"])
def login_user():
    data = request.get_json()
    email = data.get("email")

    if not email:
        return jsonify({"error": "Email required"}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT user_id AS id, name, email FROM users WHERE email=%s", (email,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify(user)

@login_bp.route("/employee", methods=["POST"])
def login_employee():
    data = request.get_json()
    emp_id = data.get("emp_id")

    if not emp_id:
        return jsonify({"error": "Employee ID required"}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT employee_id AS id, name, role, warehouse_id FROM employees WHERE employee_id=%s", (emp_id,))
    employee = cursor.fetchone()
    cursor.close()
    conn.close()

    if not employee:
        return jsonify({"error": "Employee not found"}), 404
    return jsonify(employee)
