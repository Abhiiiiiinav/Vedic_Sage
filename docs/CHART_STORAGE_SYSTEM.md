# Production-Grade Chart Storage System

## ✅ Implementation Complete

This document describes the **correct, production-grade architecture** for handling SVG charts in AstroLearn.

---

## 🎯 Core Principle

**SVG is for display only. Houses are calculated from Ascendant + Signs.**

```
Birth Data → API/Engine → SVG + Planets → Parser → Hive Storage → Display
```

---

## 📦 Components Created

### 1. **SvgChartParser** (`lib/core/services/svg_chart_parser.dart`)
- Extracts planet positions from SVG coordinates
- Maps SVG grid (4×4) to zodiac signs (South Indian style)
- Converts signs to houses using ascendant
- Validates SVG structure

**Key Method:**
```dart
Map<int, List<String>> extractHousePlanetsFromSvg(String svg, int ascendantSign)
```

### 2. **DivisionalChartModel** (`lib/core/database/models/divisional_chart_model.dart`)
- Complete chart data structure
- Stores: chartType, ascendantSign, housePlanets, SVG, metadata
- Helper methods for querying planets and houses
- Hive-compatible with TypeAdapter

**Key Fields:**
- `chartType`: 'd1', 'd9', 'd10', etc.
- `ascendantSign`: 1-12 (Aries=1, Taurus=2, etc.)
- `housePlanets`: Map<houseNumber, List<planetAbbreviations>>
- `svg`: Raw SVG string from API

### 3. **DivisionalChartModelAdapter** (`lib/core/database/models/divisional_chart_adapter.dart`)
- Hive TypeAdapter (typeId: 10)
- Binary serialization for local storage

### 4. **ChartStorageService** (`lib/core/services/chart_storage_service.dart`)
- Save/load charts to/from Hive
- Batch operations
- Query by profile, chart type, or key
- Export/import JSON
- Validation

**Key Methods:**
```dart
Future<String> saveDivisionalChart({...})
DivisionalChartModel? getChartByType(String profileId, String chartType)
List<DivisionalChartModel> getChartsForProfile(String profileId)
```

---

## 🏗️ Architecture Flow

### Correct Workflow:

1. **Fetch from API**
   ```dart
   final response = await apiService.getChartByDivision('chart/d1', birthDetails);
   ```

2. **Parse SVG**
   ```dart
   final housePlanets = SvgChartParser.extractHousePlanetsFromSvg(
     response.svg,
     ascendantSign,
   );
   ```

3. **Store in Hive**
   ```dart
   final key = await storageService.saveDivisionalChart(
     chartType: 'd1',
     svg: response.svg,
     ascendantSign: ascendantSign,
     profileId: 'user_123',
   );
   ```

4. **Load and Display**
   ```dart
   final chart = storageService.getChartByType('user_123', 'd1');
   // Display chart.svg
   // Query chart.housePlanets for house information
   ```

---

## 🔑 Key Features

### ✅ What This System Does:

1. **Separates Display from Data**
   - SVG = Visual representation only
   - Houses = Calculated from ascendant + signs

2. **Works Offline**
   - All data stored in Hive
   - No API needed after initial fetch

3. **Supports All Divisional Charts**
   - D1 (Rasi), D2 (Hora), D3 (Drekkana)
   - D9 (Navamsa), D10 (Dasamsa)
   - D12, D16, D20, D24, D27, D30, D40, D45, D60

4. **Accurate House Calculation**
   ```dart
   house = ((sign - ascendantSign + 12) % 12) + 1
   ```

5. **Rich Query API**
   - Get planets in house
   - Find house for planet
   - Get empty/occupied houses
   - Check planet-house combinations

---

## 📊 South Indian Grid Mapping

```dart
const List<List<int>> southSignGrid = [
  [12, 1, 2, 3],   // Pisces, Aries, Taurus, Gemini
  [11, 0, 0, 4],   // Aquarius, [center], Cancer
  [10, 0, 0, 5],   // Capricorn, [center], Leo
  [9, 8, 7, 6],    // Sagittarius, Scorpio, Libra, Virgo
];
```

**Visual Layout:**
```
┌─────────┬─────────┬─────────┬─────────┐
│ Pisces  │ Aries   │ Taurus  │ Gemini  │
│  (12)   │  (1)    │  (2)    │  (3)    │
├─────────┼─────────┴─────────┼─────────┤
│ Aquarius│                   │ Cancer  │
│  (11)   │     Center        │  (4)    │
├─────────┤                   ├─────────┤
│Capricorn│                   │  Leo    │
│  (10)   │                   │  (5)    │
├─────────┼─────────┬─────────┼─────────┤
│ Sagit.  │ Scorpio │ Libra   │ Virgo   │
│  (9)    │  (8)    │  (7)    │  (6)    │
└─────────┴─────────┴─────────┴─────────┘
```

---

## 🚀 Usage Examples

See `lib/examples/chart_storage_examples.dart` for complete examples:

1. Fetch and store single chart
2. Batch chart storage
3. Load and display chart
4. Query chart data
5. Manual SVG parsing
6. Complete workflow widget
7. Export/import charts

---

## ⚠️ Important Rules

### ❌ Never Do This:
```dart
// DON'T calculate houses from SVG layout
final house = (x / 100).floor(); // WRONG!
```

### ✅ Always Do This:
```dart
// DO calculate houses from ascendant + sign
final house = ((sign - ascendantSign + 12) % 12) + 1; // CORRECT!
```

---

## 🔄 Migration from Old System

If you have existing charts stored differently:

1. **Fetch fresh data from API** (most accurate)
2. **Parse SVG** using `SvgChartParser`
3. **Save using** `ChartStorageService`
4. **Delete old data**

---

## 🧪 Testing

```dart
// Test SVG parsing
final housePlanets = SvgChartParser.extractHousePlanetsFromSvg(svg, 1);
assert(housePlanets[1]!.contains('Su')); // Sun in 1st house

// Test storage
final key = await storageService.saveDivisionalChart(...);
final chart = storageService.getChartByKey(key);
assert(chart != null);

// Test validation
final isValid = storageService.validateChart(chart);
assert(isValid == true);
```

---

## 📝 Next Steps (Optional Enhancements)

1. ✅ Click on SVG house → show planets
2. ✅ Render North Indian chart from same data
3. ✅ Validate API vs Engine chart differences
4. ✅ Store full divisional chart set (D1–D60)
5. ✅ Animate chart transitions
6. ✅ Add chart comparison tools
7. ✅ Export charts as images
8. ✅ Share charts with others

---

## 📚 References

- **South Indian Chart Style**: Fixed sign positions
- **Lahiri Ayanamsa**: Used by Free Astrology API
- **Divisional Charts**: D1-D60 (Parashara system)
- **Hive Storage**: Fast, offline-first local database

---

## ✨ Summary

This is the **production-grade** way real astrology apps handle charts:

1. **Fetch accurate data** from API/Engine
2. **Parse SVG** to extract positions
3. **Calculate houses** from ascendant
4. **Store everything** in Hive
5. **Display SVG** for visualization
6. **Query data** for analysis

**Result**: Accurate, offline-capable, maintainable chart system! 🎉
