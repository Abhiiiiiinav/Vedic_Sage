"""
Flask Backend for AstroLearn - Vedic Astrology SVG Chart Generator
Integrates with Free Astrology API for professional chart generation
Returns SVG in JSON format for Flutter flutter_svg package
"""

from flask import Flask, jsonify, request, Response
from flask_cors import CORS
import requests
import os
import re
import time
from datetime import datetime, timedelta
import hashlib
import json
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter web/mobile

# Free Astrology API Configuration
BASE_URL = "https://json.freeastrologyapi.com"

# API Keys loaded from .env (rotate if one fails)
API_KEYS = [
    os.environ.get("ASTRO_API_KEY_1", ""),
    os.environ.get("ASTRO_API_KEY_2", ""),
    os.environ.get("ASTRO_API_KEY_3", ""),
]
# Remove empty keys
API_KEYS = [k for k in API_KEYS if k]

# In-memory cache for charts and planetary data
# Format: { cache_key: {'svg': str, 'timestamp': datetime, 'chart_name': str} }
CHART_CACHE = {}
PLANET_CACHE = {}  # Cache for planetary data
CACHE_EXPIRY_HOURS = 128  # Cache charts for 128 hours

# API Base URL
API_BASE_URL = BASE_URL


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
    
    # Generate chart_id from birth data
    batch_chart_id = generate_chart_id(data)
    
    return jsonify({
        'success': len(results) > 0,
        'chart_id': batch_chart_id,
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


# =============================================================
# SVG POSITION EXTRACTION - South Indian Style
# =============================================================

# South Indian chart grid (4x4) - Fixed sign positions
# Each cell maps to a zodiac sign (1-12), 0 = center (unused)
SOUTH_SIGN_GRID = [
    [12, 1, 2, 3],    # Row 0: Pisces, Aries, Taurus, Gemini
    [11, 0, 0, 4],    # Row 1: Aquarius, center, center, Cancer
    [10, 0, 0, 5],    # Row 2: Capricorn, center, center, Leo
    [9, 8, 7, 6],     # Row 3: Sagittarius, Scorpio, Libra, Virgo
]

SIGN_NAMES = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
]

VALID_PLANETS = ['Su', 'Mo', 'Ma', 'Me', 'Ju', 'Ve', 'Sa', 'Ra', 'Ke']

# 27 Nakshatras with lords
NAKSHATRAS = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
    'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
]

NAKSHATRA_LORDS = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu',
    'Jupiter', 'Saturn', 'Mercury', 'Ketu', 'Venus', 'Sun',
    'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu',
    'Jupiter', 'Saturn', 'Mercury'
]


def extract_positions_from_svg(svg_content):
    """
    Extract planet positions and ascendant from South Indian style SVG.
    
    Parses <text x="X" y="Y">ABBR</text> elements, maps coordinates
    to grid cells, then maps cells to zodiac signs.
    
    Returns:
        {
            'ascendant_sign': int (1-12),
            'planet_signs': {'Su': 8, 'Mo': 4, ...},
            'planets_in_houses': {1: ['Su', 'Me'], 2: [], ...}
        }
    """
    if not svg_content or '<svg' not in svg_content:
        return {'ascendant_sign': 0, 'planet_signs': {}, 'planets_in_houses': {}}
    
    # Detect chart dimensions from viewBox or width/height
    chart_width = 400.0  # Default
    viewbox_match = re.search(r'viewBox="[\d.]+\s+[\d.]+\s+([\d.]+)\s+[\d.]+"', svg_content)
    if viewbox_match:
        chart_width = float(viewbox_match.group(1))
    else:
        width_match = re.search(r'width="([\d.]+)"', svg_content)
        if width_match:
            chart_width = float(width_match.group(1))
    
    cell_size = chart_width / 4.0
    
    # Parse text elements
    text_pattern = re.compile(
        r'<text[^>]*x="([^"]+)"[^>]*y="([^"]+)"[^>]*>([^<]+)</text>',
        re.IGNORECASE
    )
    
    ascendant_sign = 0
    planet_signs = {}
    
    for match in text_pattern.finditer(svg_content):
        x_str, y_str, raw_text = match.group(1), match.group(2), match.group(3)
        
        try:
            x = float(x_str)
            y = float(y_str)
        except ValueError:
            continue
        
        # Clean text (remove parentheses, whitespace)
        text = re.sub(r'[()\s]', '', raw_text).strip()
        
        # Map coordinates to grid cell
        col = min(int(x / cell_size), 3)
        row = min(int(y / cell_size), 3)
        col = max(0, col)
        row = max(0, row)
        
        # Get sign from grid
        sign = SOUTH_SIGN_GRID[row][col]
        if sign == 0:
            continue  # Center cells, skip
        
        # Check for Ascendant marker
        if text in ('Asc', 'As', 'Ascendant', 'ASC'):
            ascendant_sign = sign
            continue
        
        # Check for valid planet
        if text in VALID_PLANETS:
            planet_signs[text] = sign
    
    # Build house-planet mapping if we have ascendant
    planets_in_houses = {i: [] for i in range(1, 13)}
    if ascendant_sign > 0:
        for planet, sign in planet_signs.items():
            house = ((sign - ascendant_sign + 12) % 12) + 1
            planets_in_houses[house].append(planet)
    
    return {
        'ascendant_sign': ascendant_sign,
        'planet_signs': planet_signs,
        'planets_in_houses': planets_in_houses,
    }


def calculate_nakshatra(full_degree):
    """
    Calculate Nakshatra, Pada, and Lord from full degree (0-360).
    Each nakshatra spans 13°20' = 13.3333°
    Each pada spans 3°20' = 3.3333°
    """
    degree = full_degree % 360
    nakshatra_span = 360.0 / 27.0  # 13.3333°
    pada_span = nakshatra_span / 4.0  # 3.3333°
    
    nakshatra_index = int(degree / nakshatra_span)
    nakshatra_index = min(nakshatra_index, 26)
    
    pada = int((degree % nakshatra_span) / pada_span) + 1
    pada = min(max(pada, 1), 4)
    
    return {
        'nakshatra': NAKSHATRAS[nakshatra_index],
        'pada': pada,
        'lord': NAKSHATRA_LORDS[nakshatra_index],
        'nakshatra_index': nakshatra_index,
    }


# ============== Full Kundali Endpoint ==============
@app.route('/kundali/full', methods=['POST'])
def get_full_kundali():
    """
    Combined endpoint: returns SVG + extracted positions for all requested divisions.
    Also fetches D1 planet data (degrees, nakshatras).
    
    JSON Body:
    {
        "year": 2003, "month": 11, "date": 22,
        "hours": 13, "minutes": 30, "seconds": 0,
        "latitude": 14.82, "longitude": 74.1359,
        "timezone": 5.5,
        "ayanamsha": "lahiri",
        "divisions": ["d1", "d9", "d10"]  // optional, defaults to all
    }
    
    Returns:
    {
        "success": true,
        "divisions": {
            "d1": {"svg": "...", "ascendant_sign": 4, "planet_signs": {...}},
            "d9": {"svg": "...", "ascendant_sign": 7, "planet_signs": {...}},
            ...
        },
        "d1_planets": {
            "Sun": {"fullDegree": 216.5, "sign": 8, "nakshatra": "Jyeshtha", ...},
            ...
        },
        "nakshatras": {
            "Sun": {"nakshatra": "Jyeshtha", "pada": 3, "lord": "Mercury"},
            ...
        }
    }
    """
    data = request.get_json() or {}
    requested_divisions = data.get('divisions', list(CHART_ENDPOINTS.keys()))
    
    divisions_result = {}
    errors = {}
    
    # 1. Fetch SVG for each requested division and extract positions
    for div_key in requested_divisions:
        div_key = div_key.lower()
        if div_key not in CHART_ENDPOINTS:
            errors[div_key] = f'Unknown division: {div_key}'
            continue
        
        endpoint = CHART_ENDPOINTS[div_key]
        result = fetch_chart_svg(endpoint, data, chart_type=div_key)
        
        if result['success']:
            svg = result['svg']
            positions = extract_positions_from_svg(svg)
            
            divisions_result[div_key] = {
                'svg': svg,
                'chart_name': CHART_NAMES.get(div_key, div_key),
                'ascendant_sign': positions['ascendant_sign'],
                'ascendant_name': SIGN_NAMES[positions['ascendant_sign'] - 1] if positions['ascendant_sign'] > 0 else 'Unknown',
                'planet_signs': positions['planet_signs'],
                'planets_in_houses': {str(k): v for k, v in positions['planets_in_houses'].items()},
            }
        else:
            errors[div_key] = result.get('error', 'Unknown error')
    
    # 2. Fetch D1 planet data (degrees, retrograde, etc.) from /planets API
    d1_planets = {}
    nakshatras_result = {}
    
    planet_result = fetch_planetary_data(data)
    if planet_result['success']:
        output = planet_result['output']
        
        # Parse the output list [{"0": {...}}, {"1": {...}}, ...]
        if isinstance(output, list):
            for item in output:
                if isinstance(item, dict):
                    for key, planet_data in item.items():
                        if isinstance(planet_data, dict) and 'name' in planet_data:
                            name = planet_data['name']
                            full_degree = planet_data.get('fullDegree', 0)
                            
                            # Calculate nakshatra from degree
                            nak_data = calculate_nakshatra(full_degree)
                            
                            d1_planets[name] = {
                                'fullDegree': full_degree,
                                'normDegree': planet_data.get('normDegree', 0),
                                'sign': planet_data.get('current_sign', 0),
                                'sign_name': SIGN_NAMES[planet_data.get('current_sign', 1) - 1] if planet_data.get('current_sign', 0) > 0 else 'Unknown',
                                'house': planet_data.get('house_number', 0),
                                'isRetro': planet_data.get('isRetro', False),
                                'nakshatra': nak_data['nakshatra'],
                                'nakshatra_pada': nak_data['pada'],
                                'nakshatra_lord': nak_data['lord'],
                            }
                            
                            # Also build separate nakshatras map
                            if name != 'Ascendant':
                                nakshatras_result[name] = nak_data
    
    chart_id = generate_chart_id(data)
    
    return jsonify({
        'success': len(divisions_result) > 0,
        'chart_id': chart_id,
        'divisions': divisions_result,
        'd1_planets': d1_planets,
        'nakshatras': nakshatras_result,
        'errors': errors if errors else None,
        'count': len(divisions_result),
    })


if __name__ == '__main__':
    print("\n" + "=" * 50)
    print("   AstroLearn Chart API Server v3.0.0")
    print("   Full Kundali: SVG + Positions + Nakshatras")
    print("=" * 50)
    print("\nEndpoints:")
    print("  GET  /kundali          - Get chart with query params")
    print("  POST /kundali/full     - Full kundali (all divisions + planets)")
    print("  POST /chart/<division> - Single divisional chart")
    print("  POST /charts/batch     - Multiple charts")
    print("  POST /planets          - D1 planetary data")
    print("  GET  /rasi             - Quick D1 chart")
    print("  GET  /navamsa          - Quick D9 chart")
    print(f"\nCaching: {CACHE_EXPIRY_HOURS} hours")
    print("\nStarting server on http://0.0.0.0:5000")
    print("=" * 50 + "\n")
    
    app.run(host='0.0.0.0', port=5000, debug=True)
