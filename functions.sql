# Create a new user
def create_user(name, email, password, phone, pincode):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO users (name, email, password, phone, pincode)
        VALUES (%s, %s, %s, %s, %s)
    """, (name, email, password, phone, pincode))
    conn.commit()
    cursor.close()
    conn.close()