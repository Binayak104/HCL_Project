
import requests
import sys
import json
import time

# Inputs
if len(sys.argv) < 3:
    print("Usage: python verify_health.py <API_GATEWAY_URL> <DB_ENDPOINT>")
    sys.exit(1)

API_URL = sys.argv[1]
DB_ENDPOINT = sys.argv[2].split(':')[0]
DB_NAME = os.getenv('DB_NAME', 'vecdb')
DB_USER = os.getenv('DB_USER', 'dbadmin')
DB_PASS = os.getenv('DB_PASS', 'password123')

def check_db():
    print(f"\n[1/2] Checking pgvector connection at {DB_ENDPOINT}...")
    try:
        import psycopg2
        conn = psycopg2.connect(
            host=DB_ENDPOINT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            connect_timeout=5
        )
        with conn.cursor() as cur:
            cur.execute("SELECT extname FROM pg_extension WHERE extname = 'vector';")
            if cur.fetchone():
                print("✅ SUCCESS: PostgreSQL + pgvector is healthy.")
                return True
        conn.close()
        return False
    except Exception as e:
        print(f"❌ FAILURE: Could not connect to DB. Error: {e}")
        return False

def check_backend_api():
    print(f"\n[2/2] Checking Backend API at {API_URL}...")
    
    url = f"{API_URL}/assess"
    payload = {
        "engagement_details": "Test verification of the system infrastructure."
    }
    
    try:
        response = requests.post(url, json=payload, headers={"Content-Type": "application/json"}, timeout=10)
        
        print(f"   Status Code: {response.status_code}")
        if response.status_code == 200:
            print("✅ SUCCESS: Backend API processed the request.")
            return True
        else:
            print(f"❌ FAILURE: Backend returned status {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ FAILURE: Could not connect to Backend API. Error: {e}")
        return False

if __name__ == "__main__":
    print("=== Infrastructure Health Check ===")
    db_ok = check_db()
    api_ok = check_backend_api()
    
    if db_ok and api_ok:
        print("\n🎉 ALL SYSTEMS GO! Infrastructure is healthy.")
        sys.exit(0)
    else:
        print("\n💥 ISSUES DETECTED. See above for details.")
        sys.exit(1)
