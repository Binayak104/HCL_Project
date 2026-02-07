
import urllib.request
import json
import time

def verify_chroma():
    url = "http://localhost:8000/api/v1/heartbeat"
    print(f"Checking ChromaDB at {url}...")
    
    max_retries = 5
    for i in range(max_retries):
        try:
            with urllib.request.urlopen(url) as response:
                if response.status == 200:
                    data = json.loads(response.read().decode())
                    print("SUCCESS: ChromaDB is running and accessible!")
                    print(f"Response: {data}")
                    return True
        except Exception as e:
            print(f"Attempt {i+1}/{max_retries}: Failed to connect. Error: {e}")
            if i < max_retries - 1:
                print("Retrying in 2 seconds...")
                time.sleep(2)
    
    print("FAILURE: Could not connect to ChromaDB after multiple attempts.")
    return False

if __name__ == "__main__":
    verify_chroma()
