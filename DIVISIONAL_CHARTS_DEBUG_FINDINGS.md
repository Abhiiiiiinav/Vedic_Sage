# Divisional Charts Debug Findings

## Issue Summary
The divisional charts are not displaying correctly because the varga data is being found but not processed properly.

## Debug Output Analysis

From the console output, I can see:

```
🎯 CHART DATA AVAILABLE:
  Has vargas: true (keys: [D1, D2, D3, D4, D7, D9, D10, D12, D16, D20, D24, D27, D30, D40, D45, D60])
  Has apiPlanets: true
  Has divisionalExtracted: true
  Has divisionalSvgs: true

═══════════════════════════════════════════════════
📊 LOADING VARGA DATA FROM LOCAL CALCULATIONS
Available varga keys: [D1, D2, D3, D4, D7, D9, D10, D12, D16, D20, D24, D27, D30, D40, D45, D60]
═══════════════════════════════════════════════════

🔍 Processing D1 (key: d1)
  Looking for key: D1
🔍 Processing D2 (key: d2)
  Looking for key: D2
... (continues for all divisions)
```

## Key Findings

1. **Varga Data EXISTS**: The local varga calculations are present with all 16 divisions
2. **Keys Match**: The code is correctly looking for uppercase keys (D1, D2, etc.) which match the varga data
3. **Processing Stops**: After "Looking for key: D2", there's no further output, suggesting the data check fails

## Root Cause

The issue is likely in one of these areas:

### Possibility 1: Data Type Mismatch
The `varga` variable might not be recognized as a Map:
```dart
if (varga is! Map) continue;  // This might be failing
```

### Possibility 2: Missing Planet Data
The varga data structure might be missing `planetSigns` or `ascendantSign`:
```dart
final rawPlanetSigns = varga['planetSigns'] ?? varga['planet_signs'];
```

### Possibility 3: Key Storage Mismatch
The data is loaded but stored with wrong keys:
```dart
_extractions[div.key] = extraction;  // div.key is lowercase "d1"
```
But later accessed with:
```dart
_extractions[div.key]  // Still lowercase, should work
```

## Next Steps to Debug

### Step 1: Check Varga Data Structure
Add this debug code after finding varga:
```dart
if (varga is Map) {
  debugPrint('  ✅ ${div.label} is a Map');
  debugPrint('  Keys: ${varga.keys.toList()}');
  debugPrint('  ascendantSign: ${varga['ascendantSign']}');
  debugPrint('  planetSigns type: ${varga['planetSigns'].runtimeType}');
}
```

### Step 2: Check Planet Signs Processing
```dart
if (rawPlanetSigns is Map) {
  debugPrint('  🪐 Planet signs found: ${rawPlanetSigns.length} entries');
  rawPlanetSigns.forEach((key, value) {
    debugPrint('     $key: $value');
  });
}
```

### Step 3: Verify Extraction Storage
```dart
if (extraction.hasData) {
  _extractions[div.key] = extraction;
  debugPrint('  ✅ Stored ${div.label} with key "${div.key}"');
  debugPrint('  Planets stored: ${extraction.planetSigns.length}');
}
```

## Expected Varga Data Structure

Based on `buildAllVargas` in `accurate_kundali_engine.dart`:

```dart
{
  'D1': {
    'division': 1,
    'ascendantSign': 11,  // Aquarius
    'planetSigns': {
      'Sun': 8,      // Scorpio
      'Moon': 6,     // Virgo
      'Mars': 11,    // Aquarius
      'Mercury': 8,  // Scorpio
      'Jupiter': 5,  // Leo
      'Venus': 9,    // Sagittarius
      'Saturn': 3,   // Gemini
      'Rahu': 1,     // Aries
      'Ketu': 7      // Libra
    }
  },
  'D2': { ... },
  ...
}
```

## Planet Name Normalization Issue

The varga data uses full planet names ('Sun', 'Moon', etc.) but the code expects abbreviations ('Su', 'Mo', etc.).

The `_normalizePlanetAbbrev` method should handle this:
```dart
String? _normalizePlanetAbbrev(String raw) {
  const fullToAbbrev = {
    'sun': 'Su',
    'moon': 'Mo',
    'mars': 'Ma',
    'mercury': 'Me',
    'jupiter': 'Ju',
    'venus': 'Ve',
    'saturn': 'Sa',
    'rahu': 'Ra',
    'ketu': 'Ke',
  };
  
  final normalized = raw.trim().toLowerCase();
  return fullToAbbrev[normalized] ?? (
    _planets.contains(raw.trim()) ? raw.trim() : null
  );
}
```

## Recommended Fix

The most likely issue is that the planet names in the varga data don't match what `_normalizePlanetAbbrev` expects. 

### Quick Fix:
Update `_normalizePlanetAbbrev` to handle both cases:
```dart
String? _normalizePlanetAbbrev(String raw) {
  const fullToAbbrev = {
    'sun': 'Su',
    'moon': 'Mo',
    'mars': 'Ma',
    'mercury': 'Me',
    'jupiter': 'Ju',
    'venus': 'Ve',
    'saturn': 'Sa',
    'rahu': 'Ra',
    'ketu': 'Ke',
  };

  final trimmed = raw.trim();
  
  // Already abbreviated?
  if (_planets.contains(trimmed)) return trimmed;
  
  // Try full name
  final normalized = trimmed.toLowerCase();
  return fullToAbbrev[normalized];
}
```

## Testing Instructions

1. Open the app at: http://127.0.0.1:17616/XaBV4XX2I64=
2. Navigate to Divisional Charts Table
3. Check the console output for the new debug messages
4. Look for:
   - "✅ D2 is a Map" (confirms data structure)
   - "🪐 Planet signs found: X entries" (confirms planet data)
   - "✅ Stored D2 with key 'd2'" (confirms storage)

## Current Status

- ✅ Varga data is being generated correctly
- ✅ Keys match between data and lookup
- ❌ Data processing stops after key lookup
- ❓ Need to verify data structure and planet name format

---

**App URL**: http://127.0.0.1:17616/XaBV4XX2I64=
**Last Updated**: Just now
**Status**: Debugging in progress
