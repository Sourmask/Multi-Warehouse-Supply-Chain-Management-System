from flask import Blueprint, jsonify, request
from config.db import get_db_connection

packer_bp = Blueprint('packer', __name__)

@packer_bp.route('/api/packer/jobs/<int:employee_id>', methods=['GET'])
def get_packer_jobs(employee_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT 
            pq.pq_id,
            wq.warehouse_id,
            w.name AS warehouse_name,
            o.order_id,
            u.name AS user_name,
            u.pincode,
            pq.assigned_employee
        FROM packing_queue pq
        JOIN warehouse_queue wq ON pq.order_id = wq.order_id
        JOIN orders o ON pq.order_id = o.order_id
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
        WHERE latest_status.status = 'Picked'
        AND (pq.assigned_employee IS NULL OR pq.assigned_employee = %s)
        ORDER BY pq.pq_id ASC;
    """, (employee_id,))

    jobs = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(jobs)

@packer_bp.route('/api/packer/take', methods=['POST'])
def take_job():
    data = request.get_json()
    employee_id = data.get('employee_id')
    pq_id = data.get('pq_id')

    if not all([employee_id, pq_id]):
        return jsonify({"error": "Missing fields"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            UPDATE packing_queue
            SET assigned_employee = %s, notes = 'Taken by packer'
            WHERE pq_id = %s AND assigned_employee IS NULL;
        """, (employee_id, pq_id))

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

@packer_bp.route('/api/packer/complete', methods=['POST'])
def complete_job():
    data = request.get_json()
    pq_id = data.get('pq_id')
    employee_id = data.get('employee_id')

    if not all([pq_id, employee_id]):
        return jsonify({"error": "Missing fields"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT order_id FROM packing_queue WHERE pq_id = %s", (pq_id,))
        record = cursor.fetchone()
        if not record:
            return jsonify({"error": "Job not found"}), 404

        order_id = record[0]

        cursor.execute("""
            INSERT INTO order_status (order_id, status, changed_by)
            VALUES (%s, 'Packed', 'packer');
        """, (order_id,))

        cursor.execute("""
            INSERT INTO delivery (order_id, employee_id, status, dispatched_at)
            VALUES (%s, NULL, 'Ready_for_Dispatch', NULL);
        """, (order_id,))

        conn.commit()
        return jsonify({"message": "Job completed, marked Packed, and added to delivery"}), 200

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        conn.close()
