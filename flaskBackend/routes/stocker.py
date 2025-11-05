from flask import Blueprint, jsonify, request
from config.db import get_db_connection

stocker_bp = Blueprint('stocker', __name__)

@stocker_bp.route('/api/stocker/jobs/<int:employee_id>', methods=['GET'])
def get_stocker_jobs(employee_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT 
            wq.wq_id, 
            wq.order_id, 
            w.name AS warehouse_name, 
            u.name AS user_name, 
            u.pincode,
            wq.assigned_employee
        FROM warehouse_queue wq
        JOIN orders o ON wq.order_id = o.order_id
        JOIN users u ON o.user_id = u.user_id
        JOIN warehouses w ON wq.warehouse_id = w.warehouse_id
        JOIN (
            SELECT os1.order_id, os1.status
            FROM order_status os1
            JOIN (
                SELECT order_id, MAX(changed_at) AS max_time
                FROM order_status
                GROUP BY order_id
            ) os2 ON os1.order_id = os2.order_id AND os1.changed_at = os2.max_time
        ) latest_status ON o.order_id = latest_status.order_id
        WHERE latest_status.status = 'Processing'
        AND (wq.assigned_employee IS NULL OR wq.assigned_employee = %s)
        ORDER BY wq.assigned_time ASC;
    """, (employee_id,))

    jobs = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(jobs)

@stocker_bp.route('/api/stocker/take', methods=['POST'])
def take_job():
    data = request.get_json()
    employee_id = data.get('employee_id')
    wq_id = data.get('wq_id')

    if not all([employee_id, wq_id]):
        return jsonify({"error": "Missing fields"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            UPDATE warehouse_queue
            SET assigned_employee = %s, notes = 'Taken by stocker'
            WHERE wq_id = %s AND assigned_employee IS NULL;
        """, (employee_id, wq_id))

        if cursor.rowcount == 0:
            return jsonify({"error": "Job already taken by someone else"}), 400

        conn.commit()
        return jsonify({"message": "Job assigned successfully"}), 200

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        conn.close()

@stocker_bp.route('/api/stocker/complete', methods=['POST'])
def complete_job():
    data = request.get_json()
    wq_id = data.get('wq_id')
    employee_id = data.get('employee_id')

    if not all([wq_id, employee_id]):
        return jsonify({"error": "Missing fields"}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT order_id, warehouse_id FROM warehouse_queue WHERE wq_id = %s", (wq_id,))
        record = cursor.fetchone()
        if not record:
            return jsonify({"error": "Job not found"}), 404

        order_id = record["order_id"]
        warehouse_id = record["warehouse_id"]

        cursor.execute("""
            INSERT INTO packing_queue (order_id, warehouse_id, assigned_employee, notes)
            VALUES (%s, %s, %s, 'Transferred from stocker');
        """, (order_id, warehouse_id, employee_id))

        cursor.execute("""
            UPDATE packing_queue
            SET assigned_employee = NULL
            WHERE order_id = %s;
        """, (order_id,))

        cursor.execute("""
            INSERT INTO order_status (order_id, status, changed_by)
            VALUES (%s, 'Picked', 'stocker');
        """, (order_id,))

        conn.commit()
        return jsonify({"message": "Job completed and moved to packing queue"}), 200

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        conn.close()
