import psycopg2
import sys
import os

# Inputs
if len(sys.argv) < 2:
    print("Usage: python verify_pgvector.py <DB_ENDPOINT>")
    sys.exit(1)

DB_ENDPOINT = sys.argv[1].split(':')[0]
DB_NAME = os.getenv('DB_NAME', 'vecdb')
DB_USER = os.getenv('DB_USER', 'dbadmin')
DB_PASS = os.getenv('DB_PASS', 'password123')

def check_pgvector():
    print(f"Checking pgvector connection at {DB_ENDPOINT}...")
    try:
        conn = psycopg2.connect(
            host=DB_ENDPOINT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            connect_timeout=5
        )
        with conn.cursor() as cur:
            cur.execute("SELECT 1;")
            cur.execute("SELECT extname FROM pg_extension WHERE extname = 'vector';")
            extension = cur.fetchone()
            if extension:
                print("✅ SUCCESS: PostgreSQL is reachable and pgvector extension is installed.")
            else:
                print("⚠️ WARNING: PostgreSQL is reachable but pgvector extension is NOT installed.")
        conn.close()
        return True
    except Exception as e:
        print(f"❌ FAILURE: Could not connect to PostgreSQL. Error: {e}")
        return False

if __name__ == "__main__":
    if check_pgvector():
        sys.exit(0)
    else:
        sys.exit(1)
