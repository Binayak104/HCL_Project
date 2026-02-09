import requests
import json
import sys

# API Endpoint (Production/App Runner)
API_URL = "https://whurf4d6si.execute-api.us-east-1.amazonaws.com"
ENDPOINT = f"{API_URL}/assess"

# High Risk Scenario
high_risk_input = "The worker is required to work 9am-5pm Monday to Friday at the client's office. The client provides all equipment including laptop and phone. The worker reports to a line manager who assigns daily tasks and supervises the work. The worker must ask for permission to take time off. The worker manages client staff and conducts their performance reviews. The worker is integrated into the client's organization chart and receives staff benefits like gym membership and subsidized meals. The worker cannot provide a substitute and must perform the work personally. The worker is paid a fixed monthly salary regardless of project completion. This is a role that was previously held by a permanent employee."

def test_high_risk():
    print(f"Testing High Risk Input: {high_risk_input[:50]}...")
    try:
        response = requests.post(ENDPOINT, json={"engagement_details": high_risk_input})
        
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print("Response Body:")
            print(json.dumps(data, indent=2))
            
            if data.get("risk_score") == "High":
                print("\nSUCCESS: Input triggered High Risk score.")
            else:
                print(f"\nWARNING: Input triggered {data.get('risk_score')} Risk score.")
        else:
            print(f"Error: {response.text}")
            
    except Exception as e:
        print(f"Exception: {e}")

if __name__ == "__main__":
    test_high_risk()
