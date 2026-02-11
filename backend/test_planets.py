import requests
import json

# Local backend URL
URL = "http://localhost:5000/planets"

# Sample Birth Details
PAYLOAD = {
    "year": 2003,
    "month": 11,
    "date": 22,
    "hours": 13,
    "minutes": 30,
    "seconds": 0,
    "latitude": 14.8200,
    "longitude": 74.1359,
    "timezone": 5.5,
    "config": {
        "observation_point": "topocentric",
        "ayanamsha": "lahiri"
    }
}

print(f"Fetching Planetry Data from {URL}...")
try:
    response = requests.post(URL, json=PAYLOAD)
    
    if response.status_code == 200:
        data = response.json()
        if data['success']:
            print("\nSuccess! Here are the Planet Details:")
            output = data['output']
            
            # The API returns a list of single-key dicts: [{"0": {...}}, {"1": {...}}]
            # Let's iterate and print nicely
            for item in output:
                for key, planet in item.items():
                    print(f"Name: {planet['name']}")
                    print(f"   - Full Degree: {planet['fullDegree']:.4f}")
                    print(f"   - Norm Degree: {planet['normDegree']:.4f}")
                    print(f"   - Sign: {planet['current_sign']}")
                    print(f"   - House: {planet.get('house_number', 'N/A')}")
                    print(f"   - Retrograde: {planet['isRetro']}")
                    print("-" * 30)
        else:
            print("API returned error:", data.get('error'))
    else:
        print(f"Server Error {response.status_code}: {response.text}")

except Exception as e:
    print(f"Connection Failed: {e}")
