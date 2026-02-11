# AstroLearn — Complete Project Documentation

> A production-grade Vedic Astrology learning & analysis mobile app built with Flutter + Flask.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Backend (Flask API)](#backend-flask-api)
5. [Core Layer](#core-layer)
6. [Features](#features)
7. [Shared Widgets](#shared-widgets)
8. [Data Flow](#data-flow)
9. [Setup & Running](#setup--running)
10. [API Reference](#api-reference)

---

## Architecture Overview

```
┌──────────────────────────────────────────────────┐
│                   Flutter App                     │
│                                                   │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐   │
│  │ Features  │  │  Shared  │  │     App       │   │
│  │ (Screens) │  │ (Widgets)│  │ (Theme/Routes)│   │
│  └─────┬─────┘  └──────────┘  └───────────────┘   │
│        │                                          │
│  ┌─────▼──────────────────────────────────────┐   │
│  │              Core Layer                     │   │
│  │  ┌────────┐ ┌────────┐ ┌────────────────┐  │   │
│  │  │Services│ │ Astro  │ │   Database     │  │   │
│  │  │(API,AI)│ │Engines │ │ (Hive/Models)  │  │   │
│  │  └───┬────┘ └────────┘ └────────────────┘  │   │
│  │      │                                      │   │
│  │  ┌───▼────┐ ┌────────┐ ┌──────────┐        │   │
│  │  │ Repos  │ │ Stores │ │Constants │        │   │
│  │  │(Cache) │ │(State) │ │  (Data)  │        │   │
│  │  └────────┘ └────────┘ └──────────┘        │   │
│  └─────────────────────────────────────────────┘   │
└──────────────────────┬───────────────────────────┘
                       │ HTTP
              ┌────────▼────────┐
              │   Flask Backend  │
              │  (Chart Proxy)   │
              └────────┬─────────┘
                       │
              ┌────────▼────────┐
              │ Free Astrology  │
              │      API        │
              └─────────────────┘
```

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter 3.x / Dart | Cross-platform mobile UI |
| **Backend** | Flask (Python) | Chart proxy + caching |
| **Database** | Hive (local) | Profile, chart, & cache storage |
| **AI** | Google Gemini API | Astrological interpretations |
| **Charts** | Free Astrology API | SVG birth charts (D1–D60) |
| **Rendering** | `flutter_svg`, `kundali_chart` | SVG display + interactive charts |
| **Crypto** | `crypto` (SHA256) | Deterministic chart IDs |

---

## Project Structure

```
AstroLearn/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app/
│   │   ├── app.dart                       # MaterialApp, routes
│   │   └── theme.dart                     # Dark cosmic theme, planet colors
│   │
│   ├── core/
│   │   ├── astro/                         # Astrological calculation engines
│   │   ├── config/                        # API keys configuration
│   │   ├── constants/                     # Static astrological reference data
│   │   ├── data/                          # City data, quiz questions
│   │   ├── database/                      # Hive DB service + models
│   │   ├── models/                        # Domain models
│   │   ├── repositories/                  # Cache-first data access
│   │   ├── services/                      # API services (Flask, Gemini, etc.)
│   │   ├── stores/                        # App-wide state singletons
│   │   └── utils/                         # Name analysis, math helpers
│   │
│   ├── features/                          # Feature modules (screen-per-feature)
│   │   ├── arudha/                        # Arudha Pada analysis
│   │   ├── calculator/                    # Birth details input
│   │   ├── chart/                         # Chart display & details
│   │   ├── daily/                         # Daily predictions
│   │   ├── dasha/                         # Vimshottari Dasha system
│   │   ├── growth/                        # Personal growth exercises
│   │   ├── home/                          # Home dashboard
│   │   ├── nakshatra/                     # Nakshatra explorer
│   │   ├── names/                         # Vedic name analysis
│   │   ├── panchang/                      # Hindu calendar/almanac
│   │   ├── profile/                       # User profile management
│   │   ├── questions/                     # Ask-the-astrologer AI
│   │   ├── relationship/                  # Compatibility analysis
│   │   └── roadmap/                       # Learning roadmap + quizzes
│   │
│   ├── shared/
│   │   └── widgets/                       # Reusable UI components
│   │
│   └── examples/                          # Integration examples (dev reference)
│
├── backend/
│   ├── app.py                             # Flask API server
│   ├── requirements.txt                   # Python dependencies
│   ├── test_planets.py                    # API test script
│   └── README.md                          # Backend documentation
│
├── docs/                                  # Developer documentation
│   ├── DOCUMENTATION.md                   # Previous documentation
│   ├── CHART_STORAGE_SYSTEM.md            # SVG parsing architecture
│   └── VARGOTTAMA_ANALYSIS.md             # Vargottama calculation docs
│
├── pubspec.yaml                           # Flutter dependencies
├── .gitignore                             # Git exclusions
└── README.md                              # Project overview
```

---

## Backend (Flask API)

### `backend/app.py`

Flask proxy server that fetches SVG charts from the Free Astrology API with key rotation, caching, and deterministic chart IDs.

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/kundali` | GET | Fetch D1 Rasi chart with birth params as query string |
| `/chart/<division>` | POST | Fetch any divisional chart (D1–D60) |
| `/charts/batch` | POST | Fetch multiple charts in one request |
| `/rasi` | GET/POST | Shortcut for D1 chart |
| `/navamsa` | GET/POST | Shortcut for D9 chart |
| `/planets` | GET/POST | Fetch planetary positions data |
| `/planets/<division>` | POST | Planetary data for specific division |
| `/health` | GET | Health check |

**Key features:**
- **API key rotation** — 3 keys, auto-rotates on failure
- **In-memory cache** — `CHART_CACHE` and `PLANET_CACHE` dicts
- **Deterministic chart ID** — SHA256 hash of birth params, returned in every response
- **CORS enabled** — For Flutter web/mobile access

### `backend/requirements.txt`

```
flask
flask-cors
requests
```

### `backend/test_planets.py`

Test script to verify planetary data endpoints work correctly.

---

## Core Layer

### `core/astro/` — Astrological Engines

| File | Lines | Description |
|------|-------|-------------|
| `accurate_kundali_engine.dart` | 693 | **Main chart engine.** Julian Day, sidereal time, ascendant calculation (spherical trig), Lahiri Ayanamsa, planet longitudes, house assignment, Varga (divisional) charts. Matches Jagannatha Hora accuracy. |
| `vimshottari_engine.dart` | ~200 | Vimshottari Dasha period calculator. Computes Mahadasha, Antardasha, and Pratyantardasha periods from Moon's Nakshatra. |
| `darakaraka_engine.dart` | ~330 | Jaimini Chara Karaka calculator. Finds Darakaraka (spouse indicator) and all 7/8 karakas by planetary degrees. |
| `arudha_engine.dart` | ~240 | Arudha Pada calculator. Computes Arudha Lagna (AL) and Bhava Arudhas for all 12 houses. |
| `trine_compatibility_engine.dart` | ~500 | Trine (1-5-9) compatibility analysis. Evaluates Dharma, Purva Punya, and overall life patterns. |
| `dasha_lagna.dart` | ~130 | Dasha Lagna calculation. Special ascendant calculated from Vimshottari Dasha balance. |
| `house_sign_map.dart` | ~80 | House-to-sign mapping utilities. Maps house numbers to zodiac signs based on ascendant. |
| `nakshatra_dasha_map.dart` | ~50 | Nakshatra-to-Dasha-lord mapping. Maps each of 27 Nakshatras to its ruling planet. |
| `nakshatra_syllables.dart` | ~270 | Nakshatra starting syllables data. Maps Nakshatras and padas to their auspicious sounds for name analysis. |
| `kundali_orchestrator.dart` | ~20 | Placeholder for orchestrating multiple engine calculations. |

---

### `core/services/` — API & Business Services

| File | Lines | Description |
|------|-------|-------------|
| `gemini_service.dart` | 1401 | **Google Gemini AI integration.** 18+ methods for generating astrological interpretations: daily predictions, chart readings, name analysis, Dasha interpretation, Darakaraka analysis, trine compatibility, Lagna analysis, Nakshatra profiling, planetary remedies, growth exercises, Q&A. |
| `chart_api_service.dart` | ~430 | Flutter HTTP client for the Flask backend. Handles chart fetching, batch requests, URL construction for physical devices vs emulators. |
| `free_astrology_api_service.dart` | ~530 | Direct client for the Free Astrology API (planetary data endpoints). Used by chart screen for planet positions. |
| `chart_storage_service.dart` | ~220 | Saves divisional charts to Hive. Validates SVG, uses `SvgChartParser` to extract planets, creates `DivisionalChartModel`. |
| `svg_chart_parser.dart` | ~160 | Parses SVG chart text elements to extract planet positions. Maps SVG coordinates → grid cells → zodiac signs → houses. |
| `svg_chart_extractor.dart` | ~670 | Comprehensive SVG data extraction. Parses planet abbreviations, coordinates, signs, and builds house-planet maps from South Indian style charts. |
| `chart_id_generator.dart` | ~176 | Deterministic chart ID generator using SHA256. Same birth details always produce the same 16-char hex ID. Supports batch IDs and format validation. |
| `panchang_service.dart` | ~440 | Hindu calendar (Panchang) calculator. Computes Tithi, Nakshatra, Yoga, Karana, and Vara from date/time/location. |
| `user_session.dart` | ~250 | Manages the active user session. Loads saved profile from Hive, converts chart data to maps for display, extracts planet placements. |

---

### `core/database/` — Local Storage (Hive)

| File | Lines | Description |
|------|-------|-------------|
| `hive_database_service.dart` | 689 | **Main database service.** Complete CRUD for: profiles, saved charts, chart cache, SVG cache, divisional charts, learning progress, quiz scores. Includes cache key generation (SHA256) and expiry management. |
| `hive_boxes.dart` | ~35 | Box name constants for all Hive storage boxes. |
| `database.dart` | ~8 | Barrel export file. |
| `models/hive_models.dart` | ~320 | Hive type models: `UserProfileModel`, `SavedChartModel`, `PlanetPlacementModel`, `LearningProgressModel`, `ChapterProgressModel`, `QuizScoreModel`, `CacheEntryModel`. |
| `models/hive_adapters.dart` | ~370 | Hive type adapters for serialization/deserialization of all models. |
| `models/divisional_chart_model.dart` | ~245 | Model for divisional charts (D1–D60). Stores chart type, ascendant, house-planet map, SVG, planet degrees, metadata. Includes sign calculation from house + ascendant. |
| `models/divisional_chart_adapter.dart` | ~65 | Hive adapter for `DivisionalChartModel`. |

---

### `core/repositories/` — Data Access

| File | Lines | Description |
|------|-------|-------------|
| `chart_repository.dart` | ~270 | **Cache-first chart fetching.** Checks Hive cache → if miss, calls Flask API → saves to Hive. Supports single and batch operations. Includes cache validation, expiry, refresh, and stats. |

---

### `core/stores/` — App-Wide State

| File | Lines | Description |
|------|-------|-------------|
| `profile_store.dart` | ~350 | **Singleton ProfileStore.** App-wide access to active profile and charts. Provides: planet queries (house, sign), Vargottama analysis (across all charts), chart comparison, validation, export. Used by predictions, Dasha, learning, and all other features. |

---

### `core/constants/` — Static Reference Data

| File | Size | Description |
|------|------|-------------|
| `astro_data.dart` | 41 KB | Master astrological reference: planet descriptions, house meanings, sign characteristics, aspect data, dignity tables, Nakshatra details. |
| `darakaraka_education_data.dart` | 40 KB | Darakaraka educational content: planet-as-DK interpretations, sign placements, house meanings, relationship guidance. |
| `learning_roadmap.dart` | 40 KB | Complete learning curriculum: chapters, lessons, topics organized into a structured Vedic astrology course with difficulty levels. |
| `nakshatra_data.dart` | 26 KB | All 27 Nakshatras: lords, symbols, deities, characteristics, compatibility data, pada details. |
| `house_education_data.dart` | 16 KB | House (Bhava) educational content: significations, planet effects in each house. |
| `sign_education_data.dart` | 15 KB | Zodiac sign educational content: characteristics, rulers, elements, qualities. |
| `planet_education_data.dart` | 14 KB | Planet educational content: mythology, significations, strengths, weaknesses, remedies. |
| `arudha_education_data.dart` | 23 KB | Arudha Pada educational content: how others perceive you through each Bhava Arudha. |

---

### `core/data/` — App Data

| File | Size | Description |
|------|------|-------------|
| `quiz_data.dart` | 44 KB | Quiz questions for all learning chapters. Multiple-choice with explanations. |
| `indian_cities_data.dart` | 6 KB | Indian city database with coordinates and timezone offsets for birth place selection. |

---

### `core/models/` — Domain Models

| File | Description |
|------|-------------|
| `birth_details.dart` | Birth details model (name, date, time, place, coordinates). |
| `dasha_models.dart` | Dasha period models (Mahadasha, Antardasha, Pratyantardasha). |
| `gamification_models.dart` | Gamification models (XP, levels, achievements, streaks). |
| `models.dart` | General-purpose models (chart data, planet info, house data). |

---

### `core/utils/` — Utilities

| File | Description |
|------|-------------|
| `vedic_name_analyzer.dart` | Analyzes names by matching syllables to Nakshatras. Uses phonetic rules for accurate pada assignment. |
| `name_validator.dart` | 3-level name validation: format check, phonetic analysis, spelling verification. |
| `name_analysis_engine.dart` | Computes name features: syllable count, vowel ratio, phonetic patterns. |
| `house_math.dart` | House arithmetic helpers (distance, aspect calculations). |

---

### `core/config/`

| File | Description |
|------|-------------|
| `api_keys.dart` | Centralized API key management for Gemini and other services. |

---

## Features

Each feature follows the pattern: `features/<name>/screens/<name>_screen.dart`

### Chart Module (`features/chart/`) — 11 files

The largest feature module. Handles chart display, interaction, and details.

| File | Type | Description |
|------|------|-------------|
| `chart_screen.dart` | Screen | Main chart display. Shows SVG chart, planet positions, house details. Fetches from Flask API via `ChartApiService`. |
| `chart_loader_screen.dart` | Screen | Loading screen while chart is being fetched/generated. |
| `chart_gallery_screen.dart` | Screen | Gallery view of all divisional charts (D1–D60). |
| `flask_chart_demo_screen.dart` | Screen | Demo screen for testing Flask API chart generation. |
| `house_detail_screen.dart` | Screen | Detailed view of a specific house: lord, planets, significations, AI interpretation. |
| `planet_detail_screen.dart` | Screen | Detailed view of a specific planet: sign, house, dignity, Nakshatra, AI interpretation. |
| `sign_detail_screen.dart` | Screen | Detailed view of a zodiac sign: ruler, element, quality, planets placed. |
| `interactive_kundali_chart.dart` | Widget | Interactive North Indian chart with tappable houses. |
| `svg_chart_viewer.dart` | Widget | Renders SVG charts from API responses. |
| `chart_models.dart` | Model | Chart-specific data models. |
| `demo_chart_data.dart` | Data | Sample chart data for testing/demo purposes. |

---

### Dasha Module (`features/dasha/`) — 3 files

| File | Type | Description |
|------|------|-------------|
| `dasha_screen.dart` | Screen | Vimshottari Dasha timeline display. Shows current Mahadasha/Antardasha with planet colors and date ranges. |
| `dasha_timeline.dart` | Widget | Visual timeline for Dasha periods with animated progress indicators. |
| `dasha_info_card.dart` | Widget | Detail card showing Dasha period info: lord, duration, AI interpretation. |

---

### Nakshatra Module (`features/nakshatra/`) — 2 files

| File | Type | Description |
|------|------|-------------|
| `nakshatra_screen.dart` | Screen | Browse all 27 Nakshatras with search and filtering. |
| `nakshatra_detail_screen.dart` | Screen | Detailed Nakshatra view: deity, symbol, lord, characteristics, padas, AI profile. |

---

### Roadmap Module (`features/roadmap/`) — 4 files

| File | Type | Description |
|------|------|-------------|
| `roadmap_screen.dart` | Screen | Learning roadmap with chapter progression and XP tracking. |
| `chapter_detail_screen.dart` | Screen | Chapter content display with lessons and interactive elements. |
| `quiz_screen.dart` | Screen | Multiple-choice quiz for knowledge assessment after each chapter. |
| `achievements_screen.dart` | Screen | User achievements, badges, and learning milestones. |

---

### Other Feature Screens

| Feature | Screen File | Description |
|---------|-------------|-------------|
| **Home** | `home_screen.dart` | Main dashboard with navigation cards to all features. |
| **Calculator** | `birth_details_screen.dart` | Birth data input form with city search, date/time pickers. |
| **Daily** | `day_ahead_screen.dart` | AI-generated daily predictions based on transits and Panchang. |
| **Names** | `names_screen.dart` | Vedic name analysis: syllable-to-Nakshatra mapping, AI interpretation, name suggestions. |
| **Panchang** | `panchang_screen.dart` | Hindu almanac: Tithi, Nakshatra, Yoga, Karana, auspicious timings. |
| **Profile** | `profile_screen.dart` | User profile management: birth details, saved charts, settings. |
| **Questions** | `questions_screen.dart` | Ask AI: submit astrological questions with chart context for personalized answers. |
| **Growth** | `growth_screen.dart` | Personalized growth exercises based on planetary placements. |
| **Relationship** | `relationship_report_screen.dart` | Compatibility analysis using Darakaraka and trine systems. |
| **Arudha** | `arudha_screen.dart` | Arudha Pada analysis: how others perceive you through 12 Arudhas. |

---

## Shared Widgets

Located in `lib/shared/widgets/`:

| Widget | Description |
|--------|-------------|
| `app_drawer.dart` | Navigation drawer with all feature links, profile summary, and cosmic styling. |
| `animated_cosmic_background.dart` | Animated starfield background for immersive cosmic feel. |
| `astro_background.dart` | Static gradient background with cosmic theme. |
| `astro_card.dart` | Themed card with glassmorphism styling. |
| `gradient_container.dart` | Container with configurable gradient backgrounds. |
| `level_progress_bar.dart` | XP/level progress bar with animation for gamification. |
| `section_card.dart` | Section header card with icon and gradient accent. |

---

## Data Flow

### Chart Generation Flow

```
User enters birth details
       │
       ▼
BirthDetailsScreen → ChartApiService.fetchChart()
       │
       ▼
ChartRepository.getOrCreateChart()
       │
       ├── Cache HIT → Return from Hive (< 10ms)
       │
       └── Cache MISS → Flask API → Free Astrology API
                              │
                              ▼
                     SVG + chart_id returned
                              │
                              ▼
                     SvgChartParser extracts planets
                              │
                              ▼
                     DivisionalChartModel saved to Hive
                              │
                              ▼
                     ProfileStore.loadProfile()
                              │
                              ▼
                     Available app-wide via ProfileStore()
```

### AI Interpretation Flow

```
User views planet/house/chart detail
       │
       ▼
Screen calls GeminiService.generate*()
       │
       ▼
Gemini API returns interpretation
       │
       ▼
Displayed in UI with formatted sections
```

### Dasha Calculation Flow

```
ProfileStore().birthDateTime
       │
       ▼
VimshottariEngine.calculateDasha()
       │
       ▼
Moon Nakshatra → Dasha sequence
       │
       ▼
DashaScreen displays timeline
       │
       ▼
User taps period → GeminiService.generateDashaInterpretation()
```

---

## Setup & Running

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Python 3.8+
- Android Studio / VS Code

### 1. Flutter App

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build release APK
flutter build apk --release
```

### 2. Flask Backend

```bash
cd backend

# Install Python dependencies
pip install -r requirements.txt

# Run server (accessible on local network)
python app.py
# Server starts at http://0.0.0.0:5000
```

### 3. Connect App to Backend

In `lib/core/services/chart_api_service.dart`, update the IP address:

```dart
static const String _physicalDeviceUrl = 'http://YOUR_PC_IP:5000';
```

Find your PC's IP:
```bash
# Windows
ipconfig
# Look for IPv4 Address under Wi-Fi adapter
```

---

## API Reference

### Flask Endpoints

#### `GET /kundali`

Fetch D1 Rasi chart.

**Query params:** `year`, `month`, `date`, `hours`, `minutes`, `seconds`, `latitude`, `longitude`, `timezone`, `ayanamsha`

**Response:**
```json
{
  "success": true,
  "chart_id": "a3f5c8d2e1b4f6a9",
  "svg": "<svg>...</svg>",
  "chart_type": "D1",
  "chart_name": "Rasi Chart (Birth Chart)",
  "birth_details": { "date": "1995-1-15", "time": "5:30:0", ... }
}
```

---

#### `POST /chart/<division>`

Fetch any divisional chart. Divisions: `d1`–`d60`.

**Body:**
```json
{
  "year": 1995, "month": 1, "date": 15,
  "hours": 5, "minutes": 30, "seconds": 0,
  "latitude": 28.6139, "longitude": 77.209,
  "timezone": 5.5, "ayanamsha": "lahiri"
}
```

**Response:**
```json
{
  "success": true,
  "chart_id": "a3f5c8d2e1b4f6a9",
  "svg": "<svg>...</svg>",
  "chart_type": "D9",
  "chart_name": "Navamsa Chart"
}
```

---

#### `POST /charts/batch`

Fetch multiple charts at once.

**Body:** Same as above, plus `"charts": ["d1", "d9", "d10"]`

**Response:**
```json
{
  "success": true,
  "chart_id": "a3f5c8d2e1b4f6a9",
  "charts": {
    "d1": { "svg": "...", "name": "Rasi Chart" },
    "d9": { "svg": "...", "name": "Navamsa Chart" }
  },
  "count": 2
}
```

---

#### `POST /planets/<division>`

Fetch planetary position data for a specific chart division.

**Response:**
```json
{
  "success": true,
  "data": {
    "Sun": { "sign": "Capricorn", "degree": 0.45, "house": 10 },
    "Moon": { "sign": "Gemini", "degree": 15.2, "house": 3 }
  }
}
```

---

### Gemini AI Methods

All methods are on the `GeminiService` class:

| Method | Input | Output |
|--------|-------|--------|
| `generateDailyPrediction()` | Moon sign, ascendant, transits, Panchang | Daily horoscope text |
| `generateCombinationInterpretation()` | Planet, house, sign | Planet-in-sign-in-house reading |
| `generateNameAnalysis()` | Name, Nakshatra, lord | Name meaning + Nakshatra alignment |
| `generateCombinedNameAnalysis()` | Name, Nakshatra, syllables | Combined analysis + name suggestions |
| `generateStructuredNameReading()` | Computed features | Plain text interpretation |
| `generateChartInterpretation()` | Chart summary text | Full chart reading |
| `generateGrowthExercises()` | Planet, user context | Personalized exercises |
| `generateBirthChart()` | Name, DOB, TOB, POB | Chart details (AI-generated) |
| `generateDashaInterpretation()` | Dasha lords, context | Dasha period guidance |
| `generateQuestionAnswer()` | Question, category, chart | Personalized answer |
| `generateComprehensiveInterpretation()` | Full chart data, name | Complete Vedic reading |
| `generateDarakarakaAnalysis()` | DK planet, sign, house | Relationship analysis |
| `generateTrineAnalysis()` | Trine planets, name | 1-5-9 compatibility |
| `generateLagnaAnalysis()` | Lagna details | Behavioral analysis |
| `generateNakshatraProfile()` | Nakshatra, planet, sign | Psychological profile |
| `generatePlanetaryRemedies()` | Planet, sign, house, strength | Behavioral remedies |

---

## Dependencies

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.2        # iOS-style icons
  http: ^1.1.0                   # HTTP client for API calls
  kundali_chart: ^0.0.2          # North Indian chart widget
  intl: ^0.20.2                  # Date/time formatting
  flutter_svg: ^2.0.10+1         # SVG rendering for charts
  cached_network_image: ^3.3.1   # Image caching
  shared_preferences: ^2.2.0     # Simple key-value storage
  crypto: ^3.0.3                 # SHA256 for chart IDs
  hive: ^2.2.3                   # Local database
  hive_flutter: ^1.1.0           # Hive Flutter integration
```
