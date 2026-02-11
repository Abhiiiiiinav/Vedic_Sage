# 🌟 AstroLearn

A production-grade **Vedic Astrology** learning & analysis app built with **Flutter** and **Flask**.

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔮 **Birth Chart** | Generate & display D1–D60 divisional charts via Free Astrology API |
| 🪐 **Planet Analysis** | Detailed planet-in-sign-in-house interpretations (AI-powered) |
| 📅 **Dasha Timeline** | Vimshottari Dasha periods with visual timeline |
| 📖 **Learning Roadmap** | Structured Vedic astrology course with quizzes & XP |
| 🔤 **Name Analysis** | Nakshatra-based name analysis with phonetic matching |
| 🗓️ **Panchang** | Hindu almanac: Tithi, Nakshatra, Yoga, Karana |
| 💡 **Daily Predictions** | AI-generated daily horoscope from transits |
| ❓ **Ask AI** | Ask astrological questions with chart context |
| 💑 **Relationships** | Darakaraka & trine compatibility analysis |
| 🏛️ **Arudha Pada** | How others perceive you through 12 Arudhas |
| 🌱 **Growth** | Personalized growth exercises per planet |
| 🏆 **Gamification** | XP, levels, achievements, streaks |

## 🏗️ Architecture

```
Flutter App ──→ Core Layer ──→ Flask Backend ──→ Free Astrology API
                   │                              
                   ├── Hive (local cache)          
                   ├── Gemini AI (interpretations)  
                   └── Local Engines (calculations) 
```

## 🚀 Quick Start

```bash
# 1. Flutter app
flutter pub get
flutter run

# 2. Flask backend (in separate terminal)
cd backend
pip install -r requirements.txt
python app.py
```

## 📦 Tech Stack

- **Flutter 3.x** — Cross-platform mobile UI
- **Flask** — Chart proxy server with API key rotation
- **Hive** — Local database for offline support
- **Google Gemini** — AI-powered astrological interpretations
- **Free Astrology API** — SVG chart generation

## 📂 Project Structure — `lib/`

### 📁 `app/` — App Shell
| File | Description |
|------|-------------|
| `app.dart` | `MaterialApp` setup — theme, routes (`/home`, `/chart-demo`) |
| `theme.dart` | `AstroTheme` — dark cosmic theme, planet colors, gradients, text styles, Material3 dark theme |

---

### 📁 `core/astro/` — Astrological Calculation Engines
| File | Description |
|------|-------------|
| `accurate_kundali_engine.dart` | **Main engine** — Julian Day, sidereal time, ascendant (spherical trig), Lahiri Ayanamsa, planet longitudes, house assignment, all Varga charts (D1–D60). Matches Jagannatha Hora accuracy |
| `vimshottari_engine.dart` | Vimshottari Dasha calculator — Mahadasha, Antardasha, Pratyantardasha from Moon's Nakshatra |
| `darakaraka_engine.dart` | Jaimini Chara Karaka calculator — finds Darakaraka and all 7/8 karakas by planetary degrees |
| `arudha_engine.dart` | Arudha Pada calculator — Arudha Lagna (AL) and Bhava Arudhas for all 12 houses |
| `trine_compatibility_engine.dart` | Trine (1-5-9) compatibility analysis — Dharma, Purva Punya, life pattern evaluation |
| `dasha_lagna.dart` | Dasha Lagna calculation — special ascendant from Vimshottari Dasha balance |
| `house_sign_map.dart` | House-to-sign mapping utilities based on ascendant |
| `nakshatra_dasha_map.dart` | Nakshatra → Dasha lord mapping for all 27 Nakshatras |
| `nakshatra_syllables.dart` | Nakshatra starting syllables & pada-based auspicious sounds for name analysis |
| `kundali_orchestrator.dart` | Orchestrator placeholder for multi-engine calculations |

---

### 📁 `core/config/` — Configuration
| File | Description |
|------|-------------|
| `api_keys.dart` | Centralized API key management (Gemini, etc.) |

---

### 📁 `core/constants/` — Static Reference Data
| File | Size | Description |
|------|------|-------------|
| `astro_data.dart` | 41 KB | Master reference — planet descriptions, house meanings, sign characteristics, aspects, dignities, Nakshatras |
| `darakaraka_education_data.dart` | 40 KB | Darakaraka educational — planet-as-DK meanings, sign placements, relationship guidance |
| `learning_roadmap.dart` | 40 KB | Full learning curriculum — chapters, lessons, topics, difficulty levels |
| `nakshatra_data.dart` | 26 KB | 27 Nakshatras — lords, symbols, deities, characteristics, padas |
| `arudha_education_data.dart` | 23 KB | Arudha Pada education — perception through 12 Bhava Arudhas |
| `house_education_data.dart` | 16 KB | House (Bhava) education — significations, planet effects |
| `sign_education_data.dart` | 15 KB | Zodiac sign education — characteristics, rulers, elements |
| `planet_education_data.dart` | 14 KB | Planet education — mythology, significations, remedies |

---

### 📁 `core/data/` — App Data
| File | Size | Description |
|------|------|-------------|
| `quiz_data.dart` | 44 KB | Quiz questions for all learning chapters — multiple choice with explanations |
| `indian_cities_data.dart` | 6 KB | Indian city database with coordinates and timezone offsets |

---

### 📁 `core/database/` — Local Storage (Hive)
| File | Description |
|------|-------------|
| `hive_database_service.dart` | **Main DB service** — full CRUD for profiles, charts, cache, SVG, divisional charts, learning progress, quiz scores |
| `hive_boxes.dart` | Box name constants for all Hive storage boxes |
| `database.dart` | Barrel export |
| `models/hive_models.dart` | Hive models — `UserProfileModel`, `SavedChartModel`, `PlanetPlacementModel`, `LearningProgressModel`, `ChapterProgressModel`, `QuizScoreModel`, `CacheEntryModel` |
| `models/hive_adapters.dart` | Hive type adapters for serialization |
| `models/divisional_chart_model.dart` | Divisional chart model (D1–D60) — ascendant, house-planet map, SVG, degrees, sign calculation |
| `models/divisional_chart_adapter.dart` | Hive adapter for `DivisionalChartModel` |

---

### 📁 `core/models/` — Domain Models
| File | Description |
|------|-------------|
| `birth_details.dart` | Birth details model (name, date, time, place, coordinates) |
| `dasha_models.dart` | Dasha period models (Mahadasha, Antardasha, Pratyantardasha) |
| `gamification_models.dart` | Gamification models (XP, levels, achievements, streaks) |
| `models.dart` | General-purpose models (chart data, planet info, house data) |

---

### 📁 `core/repositories/` — Data Access Layer
| File | Description |
|------|-------------|
| `chart_repository.dart` | **Cache-first chart fetching** — Hive cache → Flask API → save to Hive. Supports batch operations, cache stats, refresh |

---

### 📁 `core/services/` — API & Business Services
| File | Description |
|------|-------------|
| `gemini_service.dart` | **Google Gemini AI** — 18+ methods: daily predictions, chart readings, name analysis, Dasha, Darakaraka, trine, Lagna, Nakshatra, remedies, Q&A |
| `chart_api_service.dart` | Flutter HTTP client for Flask backend — chart fetching, batch requests, device/emulator URL handling |
| `free_astrology_api_service.dart` | Direct client for Free Astrology API — planetary position data |
| `chart_storage_service.dart` | Saves divisional charts to Hive — validates SVG, extracts planets via parser |
| `svg_chart_parser.dart` | Parses SVG text elements → planet positions → house mapping |
| `svg_chart_extractor.dart` | Comprehensive SVG extraction — planet abbreviations, coordinates, signs, house-planet maps |
| `chart_id_generator.dart` | Deterministic SHA256 chart IDs — same birth details = same 16-char hex ID |
| `panchang_service.dart` | Hindu calendar calculator — Tithi, Nakshatra, Yoga, Karana, Vara |
| `user_session.dart` | Active user session — loads profile from Hive, extracts planet placements |

---

### 📁 `core/stores/` — App-Wide State
| File | Description |
|------|-------------|
| `profile_store.dart` | **Singleton ProfileStore** — app-wide chart data access, planet queries, Vargottama analysis, chart comparison, export |

---

### 📁 `core/utils/` — Utilities
| File | Description |
|------|-------------|
| `vedic_name_analyzer.dart` | Name-to-Nakshatra matching via phonetic syllable rules |
| `name_validator.dart` | 3-level name validation: format, phonetics, spelling |
| `name_analysis_engine.dart` | Name feature computation: syllable count, vowel ratio, patterns |
| `house_math.dart` | House arithmetic helpers (distance, aspect calculations) |

---

### 📁 `features/chart/` — Chart Display (11 files)
| File | Type | Description |
|------|------|-------------|
| `screens/chart_screen.dart` | Screen | Main chart — SVG display, planet positions, house details |
| `screens/chart_loader_screen.dart` | Screen | Loading animation while chart is fetched |
| `screens/chart_gallery_screen.dart` | Screen | Gallery of all divisional charts (D1–D60) |
| `screens/flask_chart_demo_screen.dart` | Screen | Flask API demo/testing screen |
| `screens/house_detail_screen.dart` | Screen | House detail — lord, planets, significations, AI reading |
| `screens/planet_detail_screen.dart` | Screen | Planet detail — sign, house, dignity, Nakshatra, AI reading |
| `screens/sign_detail_screen.dart` | Screen | Sign detail — ruler, element, quality, placed planets |
| `widgets/interactive_kundali_chart.dart` | Widget | Interactive North Indian chart with tappable houses |
| `widgets/svg_chart_viewer.dart` | Widget | Renders SVG charts from API |
| `models/chart_models.dart` | Model | Chart-specific data models |
| `data/demo_chart_data.dart` | Data | Sample chart data for testing |

---

### 📁 `features/dasha/` — Dasha System (3 files)
| File | Type | Description |
|------|------|-------------|
| `screens/dasha_screen.dart` | Screen | Vimshottari Dasha timeline — current Mahadasha/Antardasha, date ranges |
| `widgets/dasha_timeline.dart` | Widget | Visual timeline with animated progress |
| `widgets/dasha_info_card.dart` | Widget | Dasha period detail card with AI interpretation |

---

### 📁 `features/nakshatra/` — Nakshatra Explorer (2 files)
| File | Type | Description |
|------|------|-------------|
| `screens/nakshatra_screen.dart` | Screen | Browse all 27 Nakshatras with search |
| `screens/nakshatra_detail_screen.dart` | Screen | Nakshatra detail — deity, symbol, padas, AI profile |

---

### 📁 `features/roadmap/` — Learning Path (4 files)
| File | Type | Description |
|------|------|-------------|
| `screens/roadmap_screen.dart` | Screen | Learning roadmap with chapter progression & XP tracking |
| `screens/chapter_detail_screen.dart` | Screen | Chapter content with lessons & interactive elements |
| `screens/quiz_screen.dart` | Screen | Multiple-choice knowledge quizzes |
| `screens/achievements_screen.dart` | Screen | Badges, milestones, learning achievements |

---

### 📁 `features/` — Other Feature Modules (1 file each)
| Folder | Screen | Description |
|--------|--------|-------------|
| `home/` | `home_screen.dart` | Main dashboard — navigation cards to all features |
| `calculator/` | `birth_details_screen.dart` | Birth data input — city search, date/time pickers |
| `daily/` | `day_ahead_screen.dart` | AI daily predictions from transits + Panchang |
| `names/` | `names_screen.dart` | Vedic name analysis — Nakshatra matching, AI interpretation, suggestions |
| `panchang/` | `panchang_screen.dart` | Hindu almanac — Tithi, Nakshatra, Yoga, Karana, timings |
| `profile/` | `profile_screen.dart` | Profile management — birth details, saved charts, settings |
| `questions/` | `questions_screen.dart` | Ask AI — submit questions with chart context |
| `growth/` | `growth_screen.dart` | Personalized growth exercises per planetary placement |
| `relationship/` | `relationship_report_screen.dart` | Compatibility — Darakaraka & trine analysis |
| `arudha/` | `arudha_screen.dart` | Arudha Pada analysis — perception through all 12 Arudhas |

---

### 📁 `shared/widgets/` — Reusable UI Components
| File | Description |
|------|-------------|
| `app_drawer.dart` | Navigation drawer — all feature links, profile summary, cosmic styling |
| `animated_cosmic_background.dart` | Animated starfield background |
| `astro_background.dart` | Static gradient cosmic background |
| `astro_card.dart` | Themed card with glassmorphism |
| `gradient_container.dart` | Configurable gradient container |
| `level_progress_bar.dart` | Animated XP/level progress bar |
| `section_card.dart` | Section header card with icon & gradient |

---

### 📁 `examples/` — Developer Reference
| File | Description |
|------|-------------|
| `chart_caching_examples.dart` | How to use `ChartRepository` and `ProfileStore` |
| `chart_storage_examples.dart` | How to use `ChartStorageService` for saving charts |
| `vargottama_examples.dart` | Vargottama analysis examples with UI widgets |

---

## 📚 Full Documentation

See [`docs/DOCUMENTATION.md`](docs/DOCUMENTATION.md) for complete documentation including data flow diagrams, API reference, and setup guides.

## 📄 License

Private project — not for redistribution.
