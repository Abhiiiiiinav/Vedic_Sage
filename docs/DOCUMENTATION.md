# AstroLearn - Complete Project Documentation

<div align="center">

# 🌟 AstroLearn

**A Professional Vedic Astrology Learning Mobile App**

*Version 1.0.0 | Built with Flutter & Python Flask*

</div>

---

## 📋 Table of Contents

1. [Project Overview](#-project-overview)
2. [Technology Stack](#-technology-stack)
3. [Project Structure](#-project-structure)
4. [Architecture](#-architecture)
5. [Core Engine](#-core-engine---accurate-kundali-engine)
6. [Features](#-features)
7. [Backend API](#-backend-api)
8. [Services](#-services)
9. [Data Models](#-data-models)
10. [UI Components](#-ui-components)
11. [Setup & Installation](#-setup--installation)
12. [API Reference](#-api-reference)
13. [Configuration](#-configuration)
14. [Contributing](#-contributing)

---

## 🎯 Project Overview

**AstroLearn** is a comprehensive Vedic Astrology learning and chart generation mobile application. It combines traditional Jyotish wisdom with modern AI-powered interpretations to provide an educational and interactive astrology experience.

### Key Highlights

- 🔮 **Professional-Grade Calculations**: Matches accuracy of Jagannatha Hora / Parashara Light
- 🤖 **AI-Powered Insights**: Google Gemini integration for personalized interpretations
- 📊 **16+ Divisional Charts**: D1 through D60 Varga charts
- 📚 **Educational Content**: Complete learning roadmap from basics to advanced
- 🎨 **Beautiful UI**: Dark cosmic theme with smooth animations
- 📱 **Cross-Platform**: Runs on Android, iOS, Web, Windows, macOS, Linux

---

## 🛠 Technology Stack

### Frontend (Flutter)

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | SDK ≥3.0.0 |
| Language | Dart | 3.x |
| State Management | StatefulWidget | Built-in |
| HTTP Client | http | ^1.1.0 |
| SVG Rendering | flutter_svg | ^2.0.10 |
| Chart Display | kundali_chart | ^0.0.2 |
| Local Database | hive, hive_flutter | ^2.2.3, ^1.1.0 |
| Simple Storage | shared_preferences | ^2.2.0 |
| Cryptography | crypto | ^3.0.3 |
| Internationalization | intl | ^0.20.2 |

### Backend (Python)

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flask | Latest |
| CORS | flask_cors | Latest |
| HTTP Client | requests | Latest |
| API Source | Free Astrology API | v2.4.0 |

### External APIs

| API | Purpose |
|-----|---------|
| Free Astrology API | SVG chart generation, planetary data |
| Google Gemini API | AI interpretations, name analysis |

---

## 📁 Project Structure

```
AstroLearn/
├── lib/                              # Flutter source code (79 files)
│   ├── main.dart                     # App entry point
│   ├── app/                          # App configuration
│   │   ├── app.dart                  # MaterialApp setup, routing
│   │   └── theme.dart                # AstroTheme - colors, typography
│   │
│   ├── core/                         # Core business logic (37 files)
│   │   ├── astro/                    # Astrological calculation engines
│   │   │   ├── accurate_kundali_engine.dart  # Main chart engine (★ Core)
│   │   │   ├── vimshottari_engine.dart       # Dasha calculations
│   │   │   ├── arudha_engine.dart            # Arudha Lagna calculations
│   │   │   ├── darakaraka_engine.dart        # Jaimini Darakaraka
│   │   │   ├── trine_compatibility_engine.dart
│   │   │   ├── dasha_lagna.dart              # Dasha Lagna computations
│   │   │   ├── nakshatra_syllables.dart      # Name-Nakshatra mapping
│   │   │   ├── nakshatra_dasha_map.dart
│   │   │   ├── house_sign_map.dart
│   │   │   └── kundali_orchestrator.dart     # Legacy compatibility
│   │   │
│   │   ├── config/                   # Configuration
│   │   │   └── api_keys.dart         # API key management
│   │   │
│   │   ├── constants/                # Static data
│   │   │   ├── astro_data.dart               # Planet/sign/house data
│   │   │   ├── nakshatra_data.dart           # 27 Nakshatras info
│   │   │   ├── learning_roadmap.dart         # Educational content
│   │   │   ├── planet_education_data.dart
│   │   │   ├── sign_education_data.dart
│   │   │   ├── house_education_data.dart
│   │   │   ├── arudha_education_data.dart
│   │   │   └── darakaraka_education_data.dart
│   │   │
│   │   ├── data/                     # Data sources
│   │   │   ├── indian_cities_data.dart       # City database for birth place
│   │   │   ├── quiz_data.dart                # Quiz questions
│   │   │   └── api_chart_parser.dart         # API response parser
│   │   │
│   │   ├── models/                   # Data models
│   │   │   ├── models.dart                   # Core models
│   │   │   ├── birth_details.dart            # BirthDetails model
│   │   │   ├── dasha_models.dart             # Mahadasha/Antardasha
│   │   │   └── gamification_models.dart      # Progress tracking
│   │   │
│   │   ├── services/                 # API services
│   │   │   ├── gemini_service.dart           # Google Gemini AI (★)
│   │   │   ├── free_astrology_api_service.dart
│   │   │   ├── chart_api_service.dart
│   │   │   ├── chart_cache_service.dart
│   │   │   ├── panchang_service.dart
│   │   │   ├── svg_chart_extractor.dart
│   │   │   └── user_session.dart
│   │   │
│   │   └── utils/                    # Utility functions
│   │       ├── vedic_name_analyzer.dart      # Name analysis engine
│   │       ├── name_validator.dart           # Input validation
│   │       ├── name_analysis_engine.dart
│   │       └── house_math.dart
│   │
│   ├── features/                     # Feature modules (32 files)
│   │   ├── home/screens/home_screen.dart     # Main navigation hub
│   │   ├── chart/                    # Birth chart feature
│   │   │   ├── screens/
│   │   │   │   ├── chart_screen.dart         # Main chart display
│   │   │   │   ├── chart_gallery_screen.dart # All divisional charts
│   │   │   │   ├── chart_loader_screen.dart
│   │   │   │   ├── flask_chart_demo_screen.dart
│   │   │   │   ├── planet_detail_screen.dart
│   │   │   │   ├── sign_detail_screen.dart
│   │   │   │   └── house_detail_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── interactive_kundali_chart.dart
│   │   │   │   ├── svg_chart_viewer.dart
│   │   │   │   └── chart_painters.dart
│   │   │   ├── models/chart_models.dart
│   │   │   └── data/demo_chart_data.dart
│   │   │
│   │   ├── dasha/                    # Vimshottari Dasha
│   │   │   ├── screens/dasha_screen.dart
│   │   │   └── widgets/
│   │   │       ├── dasha_timeline.dart
│   │   │       └── dasha_info_card.dart
│   │   │
│   │   ├── calculator/               # Chart calculator
│   │   │   └── screens/
│   │   │       ├── birth_details_screen.dart
│   │   │       └── house_counting_page.dart
│   │   │
│   │   ├── names/screens/names_screen.dart   # AI Name Analysis
│   │   ├── nakshatra/                # Nakshatra explorer
│   │   │   └── screens/
│   │   │       ├── nakshatra_screen.dart
│   │   │       └── nakshatra_detail_screen.dart
│   │   │
│   │   ├── roadmap/                  # Learning roadmap
│   │   │   └── screens/
│   │   │       ├── roadmap_screen.dart
│   │   │       ├── chapter_detail_screen.dart
│   │   │       ├── quiz_screen.dart
│   │   │       └── achievements_screen.dart
│   │   │
│   │   ├── panchang/screens/panchang_screen.dart
│   │   ├── arudha/screens/arudha_screen.dart
│   │   ├── growth/screens/growth_screen.dart
│   │   ├── daily/screens/day_ahead_screen.dart
│   │   ├── questions/screens/questions_screen.dart
│   │   ├── profile/screens/profile_screen.dart
│   │   └── relationship/screens/relationship_report_screen.dart
│   │
│   └── shared/                       # Shared components (7 files)
│       └── widgets/
│           ├── app_drawer.dart               # Navigation drawer
│           ├── astro_background.dart         # Cosmic background
│           ├── animated_cosmic_background.dart
│           ├── astro_card.dart               # Styled card
│           ├── section_card.dart
│           ├── gradient_container.dart
│           └── level_progress_bar.dart
│
├── backend/                          # Python Flask backend
│   ├── app.py                        # Main Flask server (v2.4.0)
│   ├── requirements.txt              # Python dependencies
│   ├── test_planets.py               # API tests
│   └── README.md                     # Backend documentation
│
├── android/                          # Android platform files
├── ios/                              # iOS platform files
├── web/                              # Web platform files
├── windows/                          # Windows platform files
├── macos/                            # macOS platform files
├── linux/                            # Linux platform files
│
├── pubspec.yaml                      # Flutter dependencies
├── README.md                         # Project readme
└── DOCUMENTATION.md                  # This file
```

---

## 🏗 Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AstroLearn App                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Features  │  │   Shared    │  │     App     │             │
│  │   Modules   │  │  Widgets    │  │   Config    │             │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
│         │                │                │                     │
│  ┌──────┴────────────────┴────────────────┴──────┐             │
│  │                    CORE LAYER                 │             │
│  ├───────────────────────────────────────────────┤             │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐         │             │
│  │  │ Astro   │ │Services │ │ Models  │         │             │
│  │  │ Engines │ │  (API)  │ │         │         │             │
│  │  └────┬────┘ └────┬────┘ └─────────┘         │             │
│  └───────┼───────────┼──────────────────────────┘             │
│          │           │                                         │
├──────────┼───────────┼─────────────────────────────────────────┤
│          │           │          EXTERNAL SERVICES              │
│          │           │                                         │
│  ┌───────▼───────┐   │   ┌─────────────────────┐              │
│  │ Local Engine  │   │   │   Flask Backend     │              │
│  │ (Offline)     │   │   │   (localhost:5000)  │              │
│  └───────────────┘   │   └──────────┬──────────┘              │
│                      │              │                          │
│          ┌───────────┴──────────────┴───────────┐             │
│          │                                       │             │
│  ┌───────▼───────┐                    ┌─────────▼─────────┐   │
│  │ Google Gemini │                    │ Free Astrology    │   │
│  │     API       │                    │      API          │   │
│  └───────────────┘                    └───────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Input (Birth Details)
        │
        ▼
┌───────────────────┐
│  BirthDetails     │
│  Model            │
└────────┬──────────┘
         │
         ▼
┌───────────────────┐     Cache Hit?     ┌──────────────┐
│  ChartCacheService├────────Yes─────────►│ Return Cached│
└────────┬──────────┘                     └──────────────┘
         │ No
         ▼
┌───────────────────┐
│ AccurateKundali   │◄───── Local calculation
│ Engine            │       (offline fallback)
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ Flask Backend     │◄───── SVG chart generation
│ (Free Astro API)  │
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ Gemini Service    │◄───── AI interpretations
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ UI Display        │
│ (Chart + Insights)│
└───────────────────┘
```

---

## 🔮 Core Engine - Accurate Kundali Engine

The heart of AstroLearn is the `AccurateKundaliEngine` - a professional-grade Vedic astrology calculation engine.

### Key Features

| Feature | Description |
|---------|-------------|
| **Angular House System** | Planets placed by angular distance from Ascendant, not by sign |
| **True Obliquity** | Uses precise obliquity of ecliptic for Ascendant calculation |
| **Lahiri Ayanamsa** | Matches official Indian Ephemeris (23°51'30" at J2000) |
| **UTC Conversion** | Proper timezone handling for Julian Day calculation |
| **16 Varga Charts** | D1 through D60 divisional charts |
| **Vimshottari Dasha** | Complete 120-year Dasha cycle calculation |

### Core Functions

```dart
// Generate complete Kundali chart
KundaliResult result = AccurateKundaliEngine.generateChart(
  birthDateTime: DateTime(1990, 5, 15, 6, 30),
  latitude: 28.6139,
  longitude: 77.2090,
  timezoneOffset: 5.5,
);

// Access chart data
print(result.ascendant['signName']);        // "Taurus"
print(result.planets['Moon']['house']);     // 4
print(result.dasha['currentDasha']['lord']); // "Venus"
```

### Calculation Steps

1. **Julian Day (UT)** - Convert local time to Julian Day using UTC
2. **Greenwich Sidereal Time** - Calculate GST from Julian Day
3. **Local Sidereal Time** - Add longitude to get LST
4. **Tropical Ascendant** - Spherical trigonometry formula
5. **Lahiri Ayanamsa** - Apply sidereal correction
6. **Planet Longitudes** - Mean planet positions
7. **House Assignment** - Angular distance method
8. **Nakshatra/Pada** - 13°20' segments
9. **Divisional Charts** - All Varga calculations
10. **Vimshottari Dasha** - Based on Moon's Nakshatra

### Classes

| Class | Purpose |
|-------|---------|
| `AccurateKundaliEngine` | Main chart generation engine |
| `KundaliResult` | Complete chart data container |
| `VimshottariDasha` | Dasha period calculator |
| `ChartValidator` | Validation/debugging helper |
| `KundaliEngine` | Legacy compatibility wrapper |

---

## ✨ Features

### 1. Birth Chart (D1 Rasi)

**Screen**: `ChartScreen`  
**Purpose**: Display and interpret the main birth chart

- Interactive planet selection
- Sign/House/Nakshatra details
- AI-powered interpretations
- Planet strength analysis

### 2. Chart Gallery

**Screen**: `ChartGalleryScreen`  
**Purpose**: View all 16+ divisional charts

| Chart | Name | Purpose |
|-------|------|---------|
| D1 | Rasi | Main birth chart |
| D2 | Hora | Wealth |
| D3 | Drekkana | Siblings |
| D4 | Chaturthamsa | Fortune/Property |
| D7 | Saptamsa | Children |
| D9 | Navamsa | Marriage/Soul |
| D10 | Dasamsa | Career |
| D12 | Dwadasamsa | Parents |
| D16 | Shodasamsa | Vehicles/Comfort |
| D20 | Vimsamsa | Spirituality |
| D24 | Siddhamsa | Education |
| D27 | Nakshatramsa | Strengths |
| D30 | Trimsamsa | Evils/Misfortunes |
| D40 | Khavedamsa | Maternal legacy |
| D45 | Akshavedamsa | Paternal legacy |
| D60 | Shashtyamsa | Past life karma |

### 3. Vimshottari Dasha

**Screen**: `DashaScreen`  
**Purpose**: Display planetary period timeline

- Current Mahadasha/Antardasha
- Complete 120-year timeline
- Dasha Lagna calculation
- AI cosmic insights

### 4. AI Name Analysis

**Screen**: `EnhancedNamesScreen`  
**Purpose**: Analyze names using Vedic principles

- Nakshatra-based name matching
- Syllable analysis
- Lucky names generation
- Gemini AI interpretations

### 5. Nakshatra Explorer

**Screen**: `NakshatraScreen`  
**Purpose**: Learn about 27 Nakshatras

- Detailed Nakshatra profiles
- Ruling lords
- Characteristics
- Compatible syllables

### 6. Learning Roadmap

**Screen**: `RoadmapScreen`  
**Purpose**: Structured astrology education

- Chapter-based learning
- Quizzes and assessments
- Progress tracking
- Achievements system

### 7. Panchang

**Screen**: `PanchangScreen`  
**Purpose**: Daily astrological calendar

- Tithi, Nakshatra, Yoga, Karana
- Current planetary positions
- Auspicious/Inauspicious times

### 8. Arudha Lagna

**Screen**: `ArudhaScreen`  
**Purpose**: Jaimini Arudha calculations

- All 12 Arudha Lagnas
- Detailed interpretations
- Public perception analysis

### 9. Q&A

**Screen**: `QuestionsScreen`  
**Purpose**: Ask astrological questions

- Category-based queries
- Chart-based responses
- AI-powered answers

### 10. Growth Tracker

**Screen**: `GrowthScreen`  
**Purpose**: Personal development

- Planetary exercises
- Daily practices
- Progress monitoring

---

## 🌐 Backend API

### Flask Server (v2.4.0)

**Location**: `backend/app.py`  
**Port**: 5000  
**Features**:
- Free Astrology API integration
- API key rotation (3 keys)
- In-memory caching (128 hours)
- CORS enabled

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Health check |
| GET | `/kundali` | Get D1 chart with query params |
| POST | `/chart/<division>` | Get any divisional chart |
| POST | `/charts/batch` | Get multiple charts |
| POST | `/planets` | Get planetary data |
| GET/POST | `/rasi` | Quick D1 chart |
| GET/POST | `/navamsa` | Quick D9 chart |

### Example Request

```bash
# Get D1 Rasi Chart
curl "http://localhost:5000/kundali?year=1990&month=5&date=15&hours=6&minutes=30&latitude=28.6139&longitude=77.2090&timezone=5.5"

# Get Navamsa Chart
curl -X POST http://localhost:5000/chart/d9 \
  -H "Content-Type: application/json" \
  -d '{"year":1990,"month":5,"date":15,"hours":6,"minutes":30,"latitude":28.6139,"longitude":77.2090,"timezone":5.5}'
```

### Response Format

```json
{
  "success": true,
  "svg": "<svg>...</svg>",
  "chart_type": "D1",
  "chart_name": "Rasi Chart (Birth Chart)",
  "birth_details": {
    "date": "1990-5-15",
    "time": "6:30:0",
    "latitude": 28.6139,
    "longitude": 77.209,
    "timezone": 5.5
  }
}
```

---

## 🔌 Services

### 1. GeminiService

**File**: `lib/core/services/gemini_service.dart`  
**Purpose**: Google Gemini AI integration

#### Methods

| Method | Purpose |
|--------|---------|
| `generateDailyPrediction()` | Daily horoscope |
| `generateCombinationInterpretation()` | Planet-house-sign combo |
| `generateNameAnalysis()` | Name-based analysis |
| `generateCombinedNameAnalysis()` | Optimized name + suggestions |
| `generateChartInterpretation()` | Full chart reading |
| `generateDashaInterpretation()` | Dasha period insights |
| `generateQuestionAnswer()` | Q&A responses |
| `generateComprehensiveInterpretation()` | Complete reading |
| `generateDarakarakaAnalysis()` | Jaimini DK analysis |
| `generateTrineAnalysis()` | 1-5-9 house analysis |
| `generateLagnaAnalysis()` | Ascendant analysis |
| `generateNakshatraProfile()` | Nakshatra insights |
| `generatePlanetaryRemedies()` | Behavioral remedies |

### 2. FreeAstrologyApiService

**File**: `lib/core/services/free_astrology_api_service.dart`  
**Purpose**: External API for accurate chart data

### 3. ChartCacheService

**File**: `lib/core/services/chart_cache_service.dart`  
**Purpose**: Local caching to reduce API calls

### 4. PanchangService

**File**: `lib/core/services/panchang_service.dart`  
**Purpose**: Daily Panchang calculations

### 5. UserSession

**File**: `lib/core/services/user_session.dart`  
**Purpose**: Store current user's chart data in memory

---

## 📊 Data Models

### BirthDetails

```dart
class BirthDetails {
  final DateTime birthDateTime;
  final double latitude;
  final double longitude;
  final double timezoneOffset;
  final String? cityName;
}
```

### KundaliResult

```dart
class KundaliResult {
  final Map<String, Map<String, dynamic>> planets;
  final Map<String, dynamic> ascendant;
  final List<List<String>> houses;
  final Map<String, Map<String, dynamic>> vargas;
  final Map<String, dynamic> dasha;
  final Map<String, dynamic> meta;
  final Map<String, dynamic> validation;
}
```

### MahadashaModel

```dart
class MahadashaModel {
  final String lord;
  final String fullName;
  final DateTime startDate;
  final DateTime endDate;
  final double years;
}
```

### AntardashaModel

```dart
class AntardashaModel {
  final String lord;
  final String fullName;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
}
```

---

## 🎨 UI Components

### Theme (AstroTheme)

```dart
// Colors
static const scaffoldBackground = Color(0xFF0a0e21);
static const surfaceColor = Color(0xFF1d1e33);
static const accentGold = Color(0xFFFFD700);
static const accentCyan = Color(0xFF00FFFF);
static const accentPurple = Color(0xFF9C27B0);

// Typography
static TextStyle headingLarge;
static TextStyle headingMedium;
static TextStyle bodyLarge;
static TextStyle bodyMedium;
```

### Shared Widgets

| Widget | Purpose |
|--------|---------|
| `AstroBackground` | Cosmic gradient background |
| `AnimatedCosmicBackground` | Animated star field |
| `AstroCard` | Glassmorphic card container |
| `SectionCard` | Card with title and icon |
| `GradientContainer` | Gradient background container |
| `LevelProgressBar` | Gamification progress indicator |
| `AppDrawer` | Navigation drawer with 10 screens |

---

## 🚀 Setup & Installation

### Prerequisites

- Flutter SDK ≥3.0.0
- Python 3.8+
- Node.js (for web development)

### Installation Steps

```bash
# 1. Clone repository
git clone https://github.com/yourusername/AstroLearn.git
cd AstroLearn

# 2. Install Flutter dependencies
flutter pub get

# 3. Install Python dependencies
cd backend
pip install -r requirements.txt
cd ..

# 4. Configure API keys
# Edit lib/core/config/api_keys.dart
# Add your Google Gemini API key

# 5. Start Flask backend
cd backend
python app.py
# Server runs on http://localhost:5000

# 6. Run Flutter app
flutter run -d chrome --web-port=8080
# Or for Android:
flutter run
```

### Configuration Files

#### `lib/core/config/api_keys.dart`

```dart
class ApiKeys {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
}
```

#### `backend/app.py` (API Keys)

```python
API_KEYS = [
    "your-free-astrology-api-key-1",
    "your-free-astrology-api-key-2",
]
```

---

## 📚 API Reference

### AccurateKundaliEngine

#### generateChart()

```dart
static KundaliResult generateChart({
  required DateTime birthDateTime,
  required double latitude,
  required double longitude,
  required double timezoneOffset,
})
```

**Parameters**:
- `birthDateTime`: Local birth date and time
- `latitude`: Birth place latitude (-90 to 90)
- `longitude`: Birth place longitude (-180 to 180)
- `timezoneOffset`: Hours offset from UTC (e.g., 5.5 for IST)

**Returns**: `KundaliResult` containing complete chart data

### VimshottariEngine

#### generateMahadashas()

```dart
static List<Map<String, dynamic>> generateMahadashas({
  required String startLord,
  required double startRemainingYears,
  required DateTime birthDate,
})
```

#### getCurrentDasha()

```dart
static Map<String, dynamic> getCurrentDasha({
  required List<Map<String, dynamic>> mahadashas,
  required DateTime currentDate,
})
```

### GeminiService

#### generateNameAnalysis()

```dart
Future<String> generateNameAnalysis({
  required String name,
  required String nakshatra,
  required String nakshatraLord,
})
```

---

## ⚙️ Configuration

### Ayanamsa Options

The engine uses **Lahiri Ayanamsa** by default. The Free Astrology API supports:
- `lahiri` (default)
- `raman`
- `krishnamurti`

### Observation Point

- `topocentric` (default) - From Earth's surface
- `geocentric` - From Earth's center

### Chart Style

The Free Astrology API returns **South Indian** style charts by default.

---

## 💾 Local Database (Hive)

AstroLearn uses **Hive** for fast, lightweight local storage. Hive is a NoSQL database that stores data as key-value pairs with support for complex objects.

### Why Hive?

| Feature | Benefit |
|---------|---------|
| **No Native Dependencies** | Works on all platforms |
| **Fast** | Pure Dart implementation |
| **Lightweight** | Minimal memory footprint |
| **Type-Safe** | Custom type adapters |
| **Encrypted** | Optional encryption support |

### Database Structure

```
lib/core/database/
├── database.dart              # Barrel exports
├── hive_boxes.dart            # Box names & type IDs
├── hive_database_service.dart # Main service class
└── models/
    ├── hive_models.dart       # Data models
    └── hive_adapters.dart     # Type adapters
```

### Hive Boxes

| Box Name | Model | Purpose |
|----------|-------|---------|
| `user_profile` | UserProfileModel | User birth details & settings |
| `saved_charts` | SavedChartModel | Persisted birth charts |
| `chart_cache` | ChartCacheModel | API response cache |
| `app_settings` | AppSettingsModel | App preferences |
| `analysis_history` | AnalysisHistoryModel | AI analysis results |
| `quiz_progress` | QuizProgressModel | Learning progress |

### Usage Examples

#### Initialize Database

```dart
// In main.dart - automatically called on app start
await HiveDatabaseService().initialize();
```

#### Profile Operations

```dart
final db = HiveDatabaseService();

// Create profile
final profile = await db.createProfile(
  name: 'John Doe',
  birthDateTime: DateTime(1990, 5, 15, 6, 30),
  birthPlace: 'New Delhi',
  latitude: 28.6139,
  longitude: 77.2090,
  timezoneOffset: 5.5,
  isPrimary: true,
);

// Get primary profile
final primary = db.getPrimaryProfile();

// Update profile
await db.updateProfile(profile.copyWith(name: 'Jane Doe'));

// Get all profiles
final allProfiles = db.getAllProfiles();
```

#### Chart Operations

```dart
// Save chart
final chart = await db.saveChart(
  profileId: profile.id,
  name: 'Birth Chart',
  birthDateTime: DateTime(1990, 5, 15, 6, 30),
  birthPlace: 'New Delhi',
  latitude: 28.6139,
  longitude: 77.2090,
  timezoneOffset: 5.5,
  ascendantSign: 'Taurus',
  chartSvg: '<svg>...</svg>',
);

// Get charts for profile
final charts = db.getChartsForProfile(profile.id);
```

#### Settings Operations

```dart
// Get settings
final settings = db.getSettings();
print(settings.darkMode); // true

// Update specific setting
await db.updateSetting(key: 'ayanamsha', value: 'raman');
```

#### Cache Operations

```dart
// Cache chart data (birth charts never expire)
await db.cacheChartData(
  year: 1990, month: 5, date: 15,
  hours: 6, minutes: 30,
  latitude: 28.6139, longitude: 77.2090,
  timezone: 5.5,
  data: {'ascendant': 'Taurus', ...},
);

// Get cached data
final cached = db.getCachedChartData(
  year: 1990, month: 5, date: 15,
  hours: 6, minutes: 30,
  latitude: 28.6139, longitude: 77.2090,
  timezone: 5.5,
);
```

#### Analysis History

```dart
// Save AI analysis
await db.saveAnalysis(
  profileId: profile.id,
  analysisType: 'chart',
  query: 'Tell me about my career',
  response: 'Your 10th house...',
);

// Get history
final history = db.getAnalysisHistoryForProfile(profile.id);
```

### Data Models

#### UserProfileModel

```dart
class UserProfileModel {
  String id;
  String name;
  DateTime? birthDateTime;
  String? birthPlace;
  double? latitude;
  double? longitude;
  double? timezoneOffset;
  DateTime createdAt;
  DateTime updatedAt;
  bool isPrimary;
}
```

#### AppSettingsModel

```dart
class AppSettingsModel {
  bool darkMode;          // Default: true
  String language;        // Default: 'en'
  String ayanamsha;       // Default: 'lahiri'
  String chartStyle;      // Default: 'north'
  bool notifications;     // Default: true
  String defaultTimezone; // Default: 'Asia/Kolkata'
  bool showRetrogrades;   // Default: true
  bool showNakshatras;    // Default: true
}
```

---


## 🤝 Contributing

### Code Style

- Follow Flutter/Dart style guidelines
- Use meaningful variable names
- Add documentation for public APIs
- Write tests for new features

### Git Workflow

1. Create feature branch from `main`
2. Make changes with clear commits
3. Test thoroughly
4. Create pull request

### File Organization

- Put new screens in `lib/features/<feature>/screens/`
- Put new widgets in `lib/features/<feature>/widgets/` or `lib/shared/widgets/`
- Put new services in `lib/core/services/`
- Put constants/data in `lib/core/constants/`

---

## 📄 License

This project is for educational purposes.

---

## 👨‍💻 Author

**AstroLearn** - A Vedic Astrology Learning Application

---

## 📞 Support

For issues and feature requests, please create an issue in the repository.

---

<div align="center">

**Built with ❤️ and Flutter**

*May the stars guide your path* ✨

</div>
