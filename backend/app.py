"""
Flask Backend for AstroLearn - Vedic Astrology SVG Chart Generator
Integrates with Free Astrology API for professional chart generation
Returns SVG in JSON format for Flutter flutter_svg package
"""

from flask import Flask, jsonify, request, Response
from flask_cors import CORS
import requests
import os
import time
from datetime import datetime, timedelta
import hashlib
import json

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter web/mobile

# Free Astrology API Configuration
BASE_URL = "https://json.freeastrologyapi.com"

# API Keys (rotate if one fails)
API_KEYS = [
    "naU0VsPCyx6YGBaW215Rx3hOhezRGQdg8pjse4A8",  # New key (Primary)
    "O6sSA5hKu8atz6KDG3xQt1rlTLkUzUhJ6x1wwtLJ",
    'q4DnQlnPdM2xL4UcfOPuLaRA9JYD3aCE6lSsQGvC'  # Old key (Backup)
]

# In-memory cache for charts and planetary data
# Format: { cache_key: {'svg': str, 'timestamp': datetime, 'chart_name': str} }
CHART_CACHE = {}
PLANET_CACHE = {}  # Cache for planetary data
CACHE_EXPIRY_HOURS = 128  # Cache charts for 24 hours


def generate_chart_id(payload):
    """
    Generate deterministic chart ID from birth details
    Same birth details → same chart_id → prevents duplicate API calls
    """
    # Create sorted JSON for deterministic hashing
    sorted_json = json.dumps(payload, sort_keys=True)
    # Generate SHA256 hash and return first 16 characters
    return hashlib.sha256(sorted_json.encode()).hexdigest()[:16]


def get_cache_key(chart_type, data):
    """Generate a unique cache key based on chart type and birth data"""
    return f"{chart_type}_{data['year']}_{data['month']}_{data['date']}_{data['hours']}_{data['minutes']}_{data['latitude']}_{data['longitude']}"


def get_cached_chart(cache_key):
    """Get chart from cache if valid"""
    if cache_key in CHART_CACHE:
        cached = CHART_CACHE[cache_key]
        if datetime.now() - cached['timestamp'] < timedelta(hours=CACHE_EXPIRY_HOURS):
            print(f"[CACHE] Hit for {cache_key[:8]}...")
            return cached
    return None

def set_cached_chart(cache_key, svg, chart_name):
    """Store chart in cache"""
    CHART_CACHE[cache_key] = {
        'svg': svg,
        'timestamp': datetime.now(),
        'chart_name': chart_name
    }
    print(f"[CACHE] Stored {cache_key[:8]}... ({len(svg)} chars)")

# Chart endpoint mapping (API uses South Indian style by default)
CHART_ENDPOINTS = {
    'd1': 'horoscope-chart-svg-code',      # Rasi/Birth Chart
    'd2': 'd2-chart-svg-code',              # Hora
    'd3': 'd3-chart-svg-code',              # Drekkana
    'd4': 'd4-chart-svg-code',              # Chaturthamsa
    'd5': 'd5-chart-svg-code',              # Panchamsa
    'd6': 'd6-chart-svg-code',              # Shasthamsa
    'd7': 'd7-chart-svg-code',              # Saptamsa
    'd8': 'd8-chart-svg-code',              # Ashtamsa
    'd9': 'navamsa-chart-svg-code',         # Navamsa
    'd10': 'd10-chart-svg-code',            # Dasamsa
    'd11': 'd11-chart-svg-code',            # Rudramsa
    'd12': 'd12-chart-svg-code',            # Dwadasamsa
    'd16': 'd16-chart-svg-code',            # Shodasamsa
    'd20': 'd20-chart-svg-code',            # Vimsamsa
    'd24': 'd24-chart-svg-code',            # Siddhamsa
    'd27': 'd27-chart-svg-code',            # Nakshatramsa
    'd30': 'd30-chart-svg-code',            # Trimsamsa
    'd40': 'd40-chart-svg-code',            # Khavedamsa
    'd45': 'd45-chart-svg-code',            # Akshavedamsa
    'd60': 'd60-chart-svg-code',            # Shashtyamsa
}

CHART_NAMES = {
    'd1': 'Rasi Chart (Birth Chart)',
    'd2': 'Hora Chart',
    'd3': 'Drekkana Chart',
    'd4': 'Chaturthamsa Chart',
    'd5': 'Panchamsa Chart',
    'd6': 'Shasthamsa Chart',
    'd7': 'Saptamsa Chart',
    'd8': 'Ashtamsa Chart',
    'd9': 'Navamsa Chart',
    'd10': 'Dasamsa Chart',
    'd11': 'Rudramsa Chart',
    'd12': 'Dwadasamsa Chart',
    'd16': 'Shodasamsa Chart',
    'd20': 'Vimsamsa Chart',
    'd24': 'Siddhamsa Chart',
    'd27': 'Nakshatramsa Chart',
    'd30': 'Trimsamsa Chart',
    'd40': 'Khavedamsa Chart',
    'd45': 'Akshavedamsa Chart',
    'd60': 'Shashtyamsa Chart',
}


@app.route('/')
def home():
    """Health check endpoint"""
    return jsonify({
        'status': 'running',
        'service': 'AstroLearn Chart API',
        'version': '2.1.0',
        'api_source': 'Free Astrology API',
        'note': 'Charts are in South Indian style (API default)',
        'endpoints': {
            'GET /kundali': 'Get D1 Rasi chart with query parameters',
            'POST /chart/<division>': 'Get any divisional chart (d1, d2, d3, d9, etc.)',
            'POST /charts/batch': 'Get multiple charts at once',
        }
    })


def create_payload(data):
    """Create API payload from request data"""
    return {
        "year": int(data.get('year', 2024)),
        "month": int(data.get('month', 1)),
        "date": int(data.get('date', 1)),
        "hours": int(data.get('hours', 12)),
        "minutes": int(data.get('minutes', 0)),
        "seconds": int(data.get('seconds', 0)),
        "latitude": float(data.get('latitude', 28.6139)),
        "longitude": float(data.get('longitude', 77.2090)),
        "timezone": float(data.get('timezone', 5.5)),
        "config": {
            "observation_point": data.get('observation_point', 'topocentric'),
            "ayanamsha": data.get('ayanamsha', 'lahiri')
        }
    }


def fetch_chart_svg(endpoint, data, chart_type=None):
    """Fetch SVG chart from Free Astrology API with caching and key rotation"""
    
    # Check cache first
    cache_key = None
    if chart_type:
        cache_key = get_cache_key(chart_type, data)
        cached = get_cached_chart(cache_key)
        if cached:
            return {'success': True, 'svg': cached['svg'], 'chart_name': cached['chart_name'], 'cached': True}
    
    payload = create_payload(data)
    url = f"{API_BASE_URL}/{endpoint}"
    
    last_error = None
    
    # Try each API key
    for i, api_key in enumerate(API_KEYS):
        try:
            headers = {
                'Content-Type': 'application/json',
                'x-api-key': api_key
            }
            
            print(f"[API] Calling: {url} (Key #{i+1})")
            # Only print payload on first attempt to reduce log noise
            if i == 0:
                print(f"[API] Payload: {json.dumps(payload, indent=2)}")
            
            response = requests.post(url, headers=headers, data=json.dumps(payload), timeout=30)
            
            print(f"[API] Status: {response.status_code}")
            
            if response.status_code == 200:
                # Success!
                try:
                    api_response = response.json()
                    if 'output' in api_response:
                        svg_content = api_response['output']
                        print(f"[API] SVG extracted: {len(svg_content)} chars")
                        
                        # Cache the result
                        if chart_type and cache_key:
                            chart_name = CHART_NAMES.get(chart_type, f'Chart {chart_type.upper()}')
                            set_cached_chart(cache_key, svg_content, chart_name)
                        
                        return {'success': True, 'svg': svg_content}
                    else:
                        # Fallback: if response is direct SVG
                        return {'success': True, 'svg': response.text}
                except json.JSONDecodeError:
                    return {'success': True, 'svg': response.text}
            
            elif response.status_code == 429:
                print(f"⚠️ [API] Rate limit exceeded for key #{i+1}. Trying next key...")
                last_error = f"API error: {response.status_code} (Rate Limit)"
                continue # Try next key
            else:
                # Other error, probably bad request, don't retry same bad data
                return {'success': False, 'error': f"API error: {response.status_code}", 'details': response.text}
                
        except requests.Timeout:
            print(f"⚠️ [API] Timeout for key #{i+1}")
            last_error = 'API request timed out'
            continue
        except Exception as e:
            print(f"⚠️ [API] Error for key #{i+1}: {str(e)}")
            last_error = str(e)
            continue
            
    # If we get here, all keys failed
    return {'success': False, 'error': last_error or 'All API keys failed'}


def fetch_planetary_data(data):
    """Fetch planetary data (D1) from API with caching and rotation"""
    
    # Check cache
    cache_key = get_cache_key('planets', data)
    if cache_key in PLANET_CACHE:
        cached = PLANET_CACHE[cache_key]
        if datetime.now() - cached['timestamp'] < timedelta(hours=CACHE_EXPIRY_HOURS):
            print(f"[CACHE] Hit for planets {cache_key[:8]}...")
            return {'success': True, 'output': cached['data'], 'cached': True}

    payload = create_payload(data)
    url = f"{API_BASE_URL}/planets"
    
    last_error = None
    
    # Key Rotation Loop
    for i, api_key in enumerate(API_KEYS):
        try:
            headers = {'Content-Type': 'application/json', 'x-api-key': api_key}
            print(f"[API] Fetching Planets: {url} (Key #{i+1})")
            
            response = requests.post(url, headers=headers, data=json.dumps(payload), timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                output = result.get('output', result) # Handle if wrapped or raw
                
                # Cache
                PLANET_CACHE[cache_key] = {
                    'data': output,
                    'timestamp': datetime.now()
                }
                print(f"[CACHE] Stored planets {cache_key[:8]}...")
                return {'success': True, 'output': output}
            
            elif response.status_code == 429:
                print(f"⚠️ [API] Planets Rate limit (Key #{i+1})")
                last_error = "Rate Limit"
                continue
            else:
                return {'success': False, 'error': f"Status {response.status_code}", 'details': response.text}
        
        except Exception as e:
            print(f"⚠️ [API] Planets Error (Key #{i+1}): {e}")
            last_error = str(e)
            continue

    return {'success': False, 'error': last_error or "All keys failed"}


# ============== GET Endpoint for Kundali Chart ==============
@app.route('/kundali', methods=['GET'])
def get_kundali_chart():
    """
    GET endpoint for Kundali chart - returns D1 Rasi chart SVG in JSON
    
    Query Parameters:
        year, month, date, hours, minutes, seconds
        latitude, longitude, timezone
        ayanamsha (default: lahiri)
        division (default: d1) - can be d1, d9, d10, etc.
    
    Example:
        /kundali?year=2022&month=8&date=11&hours=6&minutes=0&latitude=17.38333&longitude=78.4666&timezone=5.5
    """
    # Get parameters from query string
    data = {
        'year': request.args.get('year', 2024),
        'month': request.args.get('month', 1),
        'date': request.args.get('date', 1),
        'hours': request.args.get('hours', 12),
        'minutes': request.args.get('minutes', 0),
        'seconds': request.args.get('seconds', 0),
        'latitude': request.args.get('latitude', 28.6139),
        'longitude': request.args.get('longitude', 77.2090),
        'timezone': request.args.get('timezone', 5.5),
        'observation_point': request.args.get('observation_point', 'topocentric'),
        'ayanamsha': request.args.get('ayanamsha', 'lahiri'),
    }
    
    division = request.args.get('division', 'd1').lower()
    
    if division not in CHART_ENDPOINTS:
        return jsonify({
            'success': False,
            'error': f'Unknown division: {division}',
            'available': list(CHART_ENDPOINTS.keys())
        }), 400
    
    endpoint = CHART_ENDPOINTS[division]
    result = fetch_chart_svg(endpoint, data, chart_type=division)
    
    # Generate chart_id for caching
    chart_id = generate_chart_id(data)
    
    if result['success']:
        return jsonify({
            'success': True,
            'chart_id': chart_id,  # Added for client-side caching
            'svg': result['svg'],
            'chart_type': division.upper(),
            'chart_name': CHART_NAMES.get(division, division),
            'birth_details': {
                'date': f"{data['year']}-{data['month']}-{data['date']}",
                'time': f"{data['hours']}:{data['minutes']}:{data['seconds']}",
                'latitude': float(data['latitude']),
                'longitude': float(data['longitude']),
                'timezone': float(data['timezone']),
            }
        })
    else:
        return jsonify({
            'success': False,
            'error': result.get('error'),
            'details': result.get('details')
        }), 500


# ============== POST Endpoint for Any Chart ==============
@app.route('/chart/<division>', methods=['POST'])
def get_chart_by_division(division):
    """
    POST endpoint for any divisional chart
    
    URL Parameter:
        division: d1, d2, d3, d4, d7, d9, d10, d12, etc.
    
    JSON Body:
    {
        "year": 2022, "month": 8, "date": 11,
        "hours": 6, "minutes": 0, "seconds": 0,
        "latitude": 17.38333, "longitude": 78.4666,
        "timezone": 5.5,
        "ayanamsha": "lahiri"
    }
    """
    division = division.lower()
    
    if division not in CHART_ENDPOINTS:
        return jsonify({
            'success': False,
            'error': f'Unknown division: {division}',
            'available': list(CHART_ENDPOINTS.keys())
        }), 400
    
    data = request.get_json() or {}
    endpoint = CHART_ENDPOINTS[division]
    result = fetch_chart_svg(endpoint, data, chart_type=division)
    
    # Generate chart_id for caching
    chart_id = generate_chart_id(data)
    
    if result['success']:
        return jsonify({
            'success': True,
            'chart_id': chart_id,  # Added for client-side caching
            'svg': result['svg'],
            'chart_type': division.upper(),
            'chart_name': CHART_NAMES.get(division, division),
        })
    else:
        return jsonify({
            'success': False,
            'error': result.get('error'),
            'details': result.get('details')
        }), 500


# ============== GET Planetary Data Endpoint ==============
@app.route('/planets', methods=['POST'])
def get_planetary_data():
    """
    Get planetary positions (D1 Rasi)
    """
    data = request.get_json() or {}
    result = fetch_planetary_data(data)
    
    if result['success']:
        return jsonify({
            'success': True,
            'output': result['output']
        })
    else:
        return jsonify({
            'success': False,
            'error': result.get('error'),
            'details': result.get('details')
        }), 500


# ============== Batch Charts Endpoint ==============
@app.route('/charts/batch', methods=['POST'])
def get_batch_charts():
    """
    Get multiple charts at once
    
    JSON Body:
    {
        "year": 2022, "month": 8, "date": 11,
        "hours": 6, "minutes": 0, "seconds": 0,
        "latitude": 17.38333, "longitude": 78.4666,
        "timezone": 5.5,
        "charts": ["d1", "d9", "d10"]
    }
    """
    data = request.get_json() or {}
    requested_charts = data.get('charts', ['d1', 'd9'])
    
    results = {}
    errors = {}
    
    for chart_key in requested_charts:
        chart_key = chart_key.lower()
        if chart_key in CHART_ENDPOINTS:
            endpoint = CHART_ENDPOINTS[chart_key]
            result = fetch_chart_svg(endpoint, data, chart_type=chart_key)
            if result['success']:
                results[chart_key] = {
                    'svg': result['svg'],
                    'name': CHART_NAMES.get(chart_key, chart_key)
                }
            else:
                errors[chart_key] = result.get('error', 'Unknown error')
        else:
            errors[chart_key] = f'Unknown division: {chart_key}'
    
    return jsonify({
        'success': len(results) > 0,
        'chart_id': chart_id,  # Added for client-side caching
        'charts': results,
        'errors': errors if errors else None,
        'count': len(results)
    })


# ============== Shortcut endpoints for common charts ==============
@app.route('/rasi', methods=['GET', 'POST'])
def get_rasi_chart():
    """Shortcut for D1 Rasi chart"""
    if request.method == 'GET':
        data = dict(request.args)
    else:
        data = request.get_json() or {}
    
    result = fetch_chart_svg('horoscope-chart-svg-code', data, chart_type='d1')
    
    if result['success']:
        return jsonify({
            'success': True,
            'svg': result['svg'],
            'chart_type': 'D1',
            'chart_name': 'Rasi Chart (Birth Chart)',
        })
    return jsonify({'success': False, 'error': result.get('error')}), 500


@app.route('/navamsa', methods=['GET', 'POST'])
def get_navamsa_chart():
    """Shortcut for D9 Navamsa chart"""
    if request.method == 'GET':
        data = dict(request.args)
    else:
        data = request.get_json() or {}
    
    result = fetch_chart_svg('navamsa-chart-svg-code', data, chart_type='d9')
    
    if result['success']:
        return jsonify({
            'success': True,
            'svg': result['svg'],
            'chart_type': 'D9',
            'chart_name': 'Navamsa Chart',
        })
    return jsonify({'success': False, 'error': result.get('error')}), 500


if __name__ == '__main__':
    print("\n" + "=" * 50)
    print("   AstroLearn Chart API Server v2.4.0")
    print("   Using Free Astrology API + Caching + Key Rotation + Planets")
    print("=" * 50)
    print("\nEndpoints:")
    print("  GET  /kundali     - Get chart with query params")
    print("  POST /chart/d1    - D1 Rasi Chart")
    print("  POST /chart/d9    - D9 Navamsa Chart")
    print("  POST /charts/batch - Multiple charts")
    print("  GET  /rasi        - Quick D1 chart")
    print("  GET  /navamsa     - Quick D9 chart")
    print(f"\nCaching: {CACHE_EXPIRY_HOURS} hours")
    print("\nStarting server on http://0.0.0.0:5000")
    print("=" * 50 + "\n")
    
    app.run(host='0.0.0.0', port=5000, debug=True)
