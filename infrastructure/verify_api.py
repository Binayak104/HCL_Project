import requests
import json
import sys

# API Endpoint from previous output
API_URL = "https://whurf4d6si.execute-api.us-east-1.amazonaws.com/assess"

payload = {
    "engagement_details": "We are looking for a software contractor to work 9-5 under the direct supervision of the manager."
}

print(f"Testing API: {API_URL}")
try:
    response = requests.post(API_URL, json=payload, headers={"Content-Type": "application/json"})
    
    print(f"Status Code: {response.status_code}")
    print("Response Body:")
    print(response.text)
    
    if response.status_code == 200:
        print("\nSUCCESS: Backend is working correctly.")
    else:
        print("\nFAILURE: Backend returned an error.")

except Exception as e:
    print(f"\nERROR: Could not connect to API. {e}")
