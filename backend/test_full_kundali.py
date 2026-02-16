"""
Test script for the /kundali/full endpoint.
Run: cd backend && python test_full_kundali.py
"""

import requests
import json
import sys

BASE_URL = "http://localhost:5000"

# Test data: 22 Nov 2003, 1:30 PM, Goa India
TEST_DATA = {
    "year": 2003,
    "month": 11,
    "date": 22,
    "hours": 13,
    "minutes": 30,
    "seconds": 0,
    "latitude": 14.82,
    "longitude": 74.1359,
    "timezone": 5.5,
    "ayanamsha": "lahiri",
    "divisions": ["d1", "d9", "d10"]
}

def test_full_kundali():
    print("=" * 60)
    print("  Testing /kundali/full endpoint")
    print("=" * 60)
    
    try:
        response = requests.post(
            f"{BASE_URL}/kundali/full",
            json=TEST_DATA,
            timeout=120
        )
    except requests.ConnectionError:
        print("\n❌ Cannot connect to server. Start it with: python app.py")
        sys.exit(1)
    
    if response.status_code != 200:
        print(f"\n❌ HTTP {response.status_code}: {response.text[:200]}")
        sys.exit(1)
    
    data = response.json()
    
    # 1. Check success
    print(f"\n✅ Success: {data.get('success')}")
    print(f"   Chart ID: {data.get('chart_id')}")
    print(f"   Divisions returned: {data.get('count')}")
    
    # 2. Check divisions
    divisions = data.get('divisions', {})
    print(f"\n📊 Divisions ({len(divisions)}):")
    for div_key, div_data in divisions.items():
        asc_sign = div_data.get('ascendant_sign', 0)
        asc_name = div_data.get('ascendant_name', 'Unknown')
        planet_signs = div_data.get('planet_signs', {})
        has_svg = bool(div_data.get('svg'))
        print(f"   {div_key.upper()}: Asc={asc_name} ({asc_sign}), "
              f"Planets: {len(planet_signs)}, SVG: {'✅' if has_svg else '❌'}")
        if planet_signs:
            for p, s in planet_signs.items():
                sign_name = ['Ari','Tau','Gem','Can','Leo','Vir','Lib','Sco','Sag','Cap','Aqu','Pis'][s-1] if 1 <= s <= 12 else '?'
                print(f"      {p} → {sign_name} ({s})")
    
    # 3. Check D1 planet data
    d1_planets = data.get('d1_planets', {})
    print(f"\n🪐 D1 Planet Data ({len(d1_planets)}):")
    for name, pdata in d1_planets.items():
        degree = pdata.get('fullDegree', 0)
        sign = pdata.get('sign_name', '?')
        nak = pdata.get('nakshatra', '?')
        pada = pdata.get('nakshatra_pada', '?')
        retro = ' (R)' if pdata.get('isRetro') else ''
        print(f"   {name:12} {degree:7.2f}° {sign:12} {nak:20} Pada {pada}{retro}")
    
    # 4. Check Nakshatras
    nakshatras = data.get('nakshatras', {})
    print(f"\n⭐ Nakshatras ({len(nakshatras)}):")
    for name, ndata in nakshatras.items():
        nak = ndata.get('nakshatra', '?')
        pada = ndata.get('pada', '?')
        lord = ndata.get('lord', '?')
        print(f"   {name:12} {nak:20} Pada {pada}, Lord: {lord}")
    
    # 5. Validation checks
    print(f"\n{'=' * 60}")
    print("  Validation Results")
    print(f"{'=' * 60}")
    
    errors = []
    
    # Check all requested divisions are present
    for div in TEST_DATA['divisions']:
        if div not in divisions:
            errors.append(f"Missing division: {div}")
    
    # Check each division has ascendant (1-12)
    for div_key, div_data in divisions.items():
        asc = div_data.get('ascendant_sign', 0)
        if not (1 <= asc <= 12):
            errors.append(f"{div_key}: Invalid ascendant ({asc})")
    
    # Check D1 planets have degrees
    if len(d1_planets) < 7:
        errors.append(f"Too few D1 planets: {len(d1_planets)} (expected ≥7)")
    
    for name, pdata in d1_planets.items():
        if name == 'Ascendant':
            continue
        degree = pdata.get('fullDegree', -1)
        if not (0 <= degree <= 360):
            errors.append(f"{name}: Invalid degree ({degree})")
        if not pdata.get('nakshatra'):
            errors.append(f"{name}: Missing nakshatra")
    
    # Check nakshatras
    if len(nakshatras) < 7:
        errors.append(f"Too few nakshatras: {len(nakshatras)} (expected ≥7)")
    
    if errors:
        for e in errors:
            print(f"   ❌ {e}")
    else:
        print(f"   ✅ All validations passed!")
    
    print(f"\n{'=' * 60}")
    return len(errors) == 0

def test_svg_extraction():
    """Test SVG extraction with just D1"""
    print("\n\n" + "=" * 60)
    print("  Testing SVG Position Extraction (D1 only)")
    print("=" * 60)
    
    test_d1 = {**TEST_DATA, "divisions": ["d1"]}
    
    try:
        response = requests.post(
            f"{BASE_URL}/kundali/full",
            json=test_d1,
            timeout=60
        )
        data = response.json()
        
        d1 = data.get('divisions', {}).get('d1', {})
        planet_signs = d1.get('planet_signs', {})
        houses = d1.get('planets_in_houses', {})
        
        print(f"\n   Ascendant: {d1.get('ascendant_name')} ({d1.get('ascendant_sign')})")
        print(f"   Planets extracted from SVG: {len(planet_signs)}")
        
        if houses:
            print("\n   House placements:")
            for h, planets in sorted(houses.items(), key=lambda x: int(x[0])):
                if planets:
                    print(f"      House {h:>2}: {', '.join(planets)}")
        
        print(f"\n   ✅ SVG extraction test complete")
        return True
    except Exception as e:
        print(f"\n   ❌ SVG extraction test failed: {e}")
        return False


if __name__ == '__main__':
    success = test_full_kundali()
    test_svg_extraction()
    
    if success:
        print("\n\n🎉 All tests PASSED!")
    else:
        print("\n\n⚠️ Some tests FAILED. Check errors above.")
        sys.exit(1)
