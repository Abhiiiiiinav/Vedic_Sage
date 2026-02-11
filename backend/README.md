# AstroLearn Flask Backend

Python Flask backend that proxies requests to the **Free Astrology API** for generating professional SVG Kundali charts.

## Architecture

```
Flutter App ──► Flask Backend (localhost:5000) ──► Free Astrology API
                     │
                     └── Returns SVG Charts
```

## Features

- 🔲 **16 Divisional Charts** - D1 to D60 (Rasi, Navamsa, Dasamsa, etc.)
- 📊 **Professional SVG Output** - High-quality, scalable vector graphics
- 🌟 **Accurate Calculations** - Uses Lahiri Ayanamsha, Topocentric observation
- 🚀 **Batch API** - Fetch multiple charts in a single request
- 🔄 **CORS Enabled** - Works with Flutter web, mobile, and desktop

## Quick Start

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Run the Server

```bash
python app.py
```

The server will start at `http://127.0.0.1:5000/`

```
🌟 AstroLearn Chart API Server
========================================
Using Free Astrology API for chart generation

Endpoints available:
  /chart/d1  - Rasi Chart (Birth Chart)
  /chart/d9  - Navamsa Chart
  /chart/d10 - Dasamsa Chart
  /charts/all - Multiple charts at once

Starting server...
========================================
```

## API Endpoints

### Health Check
```
GET /
```

### Generate Single Chart
```
POST /chart/d1  (or d2, d3, d4, d7, d9, d10, d12, d16, d20, d24, d27, d30, d40, d45, d60)
Content-Type: application/json

{
    "year": 2022,
    "month": 8,
    "date": 11,
    "hours": 6,
    "minutes": 0,
    "seconds": 0,
    "latitude": 17.38333,
    "longitude": 78.4666,
    "timezone": 5.5,
    "ayanamsha": "lahiri"
}
```

### Generate Multiple Charts
```
POST /charts/all
Content-Type: application/json

{
    "year": 2022,
    "month": 8,
    "date": 11,
    "hours": 6,
    "minutes": 0,
    "seconds": 0,
    "latitude": 17.38333,
    "longitude": 78.4666,
    "timezone": 5.5,
    "charts": ["d1", "d9", "d10"]
}
```

## Response Formats

### SVG Response (default)
Returns raw SVG content: `Content-Type: image/svg+xml`

### JSON Response
Add `?format=json` query parameter:
```json
{
    "svg": "<svg>...</svg>",
    "chart_type": "D1",
    "name": "Rasi Chart"
}
```

## Divisional Charts Reference

| Chart | Name | Signification |
|-------|------|---------------|
| D1 | Rasi | General life & body |
| D2 | Hora | Wealth & prosperity |
| D3 | Drekkana | Siblings & courage |
| D4 | Chaturthamsa | Fortune & property |
| D7 | Saptamsa | Children & progeny |
| D9 | Navamsa | Marriage, dharma, soul purpose |
| D10 | Dasamsa | Career & profession |
| D12 | Dwadasamsa | Parents & karma from them |
| D16 | Shodasamsa | Vehicles & luxuries |
| D20 | Vimsamsa | Spiritual progress |
| D24 | Chaturvimsamsa | Education & learning |
| D27 | Saptavimsamsa | Strengths & weaknesses |
| D30 | Trimsamsa | Evils & misfortunes |
| D40 | Khavedamsa | Auspicious effects |
| D45 | Akshavedamsa | General indications |
| D60 | Shashtyamsa | Past life karma |

## Flutter Integration

### For Android Emulator
```dart
ChartApiService(customBaseUrl: 'http://10.0.2.2:5000')
```

### For iOS Simulator / Web
```dart
ChartApiService(customBaseUrl: 'http://localhost:5000')
```

### For Physical Devices
Use your machine's local IP:
```dart
ChartApiService(customBaseUrl: 'http://192.168.x.x:5000')
```

## Example Usage in Flutter

```dart
import 'package:astro_learn/core/services/chart_api_service.dart';

// Create birth details
final birthDetails = BirthDetails(
  year: 2022,
  month: 8,
  date: 11,
  hours: 6,
  minutes: 0,
  latitude: 17.38333,
  longitude: 78.4666,
  timezone: 5.5,
);

// Get D1 Rasi chart
final service = ChartApiService();
final response = await service.getD1Chart(birthDetails);

if (response.success) {
  // Use response.svg with flutter_svg
  SvgPicture.string(response.svg!);
}

// Get multiple charts at once
final batchResponse = await service.getMultipleCharts(
  birthDetails,
  charts: ['d1', 'd9', 'd10'],
);
```

## Widget Usage

```dart
// Single chart viewer
SvgChartViewer(
  birthDetails: birthDetails,
  chartType: DivisionalChart.d9,
  size: 350,
)

// Multiple charts in horizontal scroll
HorizontalChartViewer(
  birthDetails: birthDetails,
  charts: [DivisionalChart.d1, DivisionalChart.d9],
  chartSize: 300,
)

// Grid of charts
DivisionalChartsGrid(
  birthDetails: birthDetails,
  charts: [DivisionalChart.d1, DivisionalChart.d9, DivisionalChart.d10],
  crossAxisCount: 2,
)
```

## Troubleshooting

### Server Not Starting
1. Ensure Python 3.8+ is installed
2. Install dependencies: `pip install flask flask-cors requests`

### Connection Refused from Flutter
1. Verify server is running: `curl http://127.0.0.1:5000/`
2. Check correct URL for your platform
3. For physical devices, ensure same WiFi network

### API Errors
- Check internet connection (Flask needs to reach Free Astrology API)
- Verify birth details are valid (date, time, coordinates)

### SVG Not Rendering
- Ensure `flutter_svg: ^2.0.10+1` is in pubspec.yaml
- Run `flutter pub get`

## API Credits

This backend uses the [Free Astrology API](https://freeastrologyapi.com/) for chart calculations. The API provides accurate Vedic astrology calculations using the Swiss Ephemeris.
