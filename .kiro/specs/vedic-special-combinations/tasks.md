# Implementation Plan: Vedic Special Combinations (Yogas)

## Overview

This implementation adds detection and display of special Vedic astrology combinations (yogas) formed by Tithi, Nakshatra, and Vara. The system will detect 10 major yoga types including auspicious yogas (Amrit Siddhi, Siddha, Mahasiddhi, Sarvartha Siddhi, Guru Pushya, Ravi Pushya) and inauspicious combinations (Dagdha, Hutashana, Visha, Vishti Karana). Users can view active yogas, filter by purpose, and see monthly/annual special days.

## Tasks

- [x] 1. Create core data models and enums
  - Create `lib/core/models/yoga_models.dart` with YogaType enum, YogaResult class, YogaPurpose enum, and YogaDefinition class
  - Define all 10 yoga types with their properties (name, description, isAuspicious, purposes)
  - _Requirements: Data structure for yoga detection results_

- [x] 2. Create yoga data repository with static combination tables
  - Create `lib/core/data/yoga_combinations_data.dart` with all yoga combination tables
  - Implement Amrit Siddhi combinations (Tithi-Vara-Nakshatra triplets)
  - Implement Siddha yoga combinations
  - Implement Mahasiddhi yoga combinations
  - Implement Sarvartha Siddhi combinations
  - Implement Guru Pushya combinations (Thursday + Pushya nakshatra)
  - Implement Ravi Pushya combinations (Sunday + Pushya nakshatra)
  - Implement Dagdha Tithi combinations (Tithi-Vara pairs)
  - Implement Hutashana yoga combinations
  - Implement Visha yoga combinations
  - Implement Vishti Karana (Bhadra) detection rules
  - _Requirements: Static data tables for all yoga types_


- [ ] 3. Implement yoga detection engine
  - [x] 3.1 Create `lib/core/services/yoga_detection_service.dart` with main detection logic
    - Implement `detectYogas(DateTime date, double lat, double lon, double tz)` method
    - Integrate with PanchangService to get Tithi, Nakshatra, and Vara
    - Implement combination matching logic for each yoga type
    - Return List<YogaResult> with all detected yogas
    - _Requirements: Core yoga detection algorithm_
  
  - [ ]* 3.2 Write unit tests for yoga detection
    - Test Amrit Siddhi detection with known combinations
    - Test Guru Pushya detection (Thursday + Pushya)
    - Test Dagdha Tithi detection
    - Test edge cases and invalid inputs
    - _Requirements: Validation of detection accuracy_

- [x] 4. Implement purpose-based filtering service
  - Create `lib/core/services/yoga_filter_service.dart` with filtering logic
  - Implement `filterByPurpose(List<YogaResult> yogas, YogaPurpose purpose)` method
  - Implement `getAuspiciousYogas(List<YogaResult> yogas)` method
  - Implement `getInauspiciousYogas(List<YogaResult> yogas)` method
  - _Requirements: Purpose-based yoga filtering_

- [x] 5. Implement monthly and annual special days calculator
  - Create `lib/core/services/special_days_service.dart`
  - Implement `getSpecialDaysForMonth(int year, int month, double lat, double lon, double tz)` method
  - Implement `getSpecialDaysForYear(int year, double lat, double lon, double tz)` method
  - Optimize for batch date processing (detect yogas for multiple dates efficiently)
  - Return Map<DateTime, List<YogaResult>> for calendar display
  - _Requirements: Monthly and annual special days calculation_

- [ ] 6. Create yoga screen UI
  - [x] 6.1 Create `lib/features/yogas/screens/yoga_screen.dart` with main screen layout
    - Display current date's active yogas
    - Show yoga name, description, and auspiciousness indicator
    - Add date picker for selecting different dates
    - Add location selector (use current profile location)
    - Display loading and error states
    - _Requirements: Main yoga display screen_
  
  - [x] 6.2 Create yoga card widget
    - Create `lib/features/yogas/widgets/yoga_card.dart`
    - Display yoga name with icon (auspicious/inauspicious)
    - Show yoga description and significance
    - Display applicable purposes (marriage, business, etc.)
    - Use color coding (green for auspicious, red for inauspicious)
    - _Requirements: Individual yoga display component_


- [x] 7. Implement purpose filter UI
  - Create `lib/features/yogas/widgets/purpose_filter_widget.dart`
  - Display filter chips for all purposes (All, Marriage, Business, Education, Travel, Spiritual, Health)
  - Implement multi-select functionality
  - Update yoga list when filters change
  - _Requirements: Purpose-based filtering UI_

- [ ] 8. Create monthly calendar view
  - [x] 8.1 Create `lib/features/yogas/screens/monthly_yogas_screen.dart`
    - Display calendar grid for selected month
    - Mark dates with special yogas (color indicators)
    - Show yoga count badge on each date
    - Implement month navigation (previous/next)
    - _Requirements: Monthly special days calendar_
  
  - [x] 8.2 Create date cell widget with yoga indicators
    - Create `lib/features/yogas/widgets/yoga_date_cell.dart`
    - Display date number
    - Show colored dots for auspicious/inauspicious yogas
    - Display yoga count badge
    - Handle tap to show full yoga details
    - _Requirements: Calendar date cell with yoga indicators_

- [x] 9. Create annual special days list view
  - Create `lib/features/yogas/screens/annual_yogas_screen.dart`
  - Display list of all special days in the year
  - Group by month with section headers
  - Show date, weekday, and yoga names
  - Implement filtering by yoga type
  - Add search functionality for specific dates
  - _Requirements: Annual special days list_

- [ ] 10. Integrate with existing Panchang screen
  - [x] 10.1 Add yoga section to Panchang screen
    - Modify `lib/features/panchang/screens/panchang_screen.dart`
    - Add "Special Yogas" section below existing panchang data
    - Display active yogas for the selected date
    - Add "View All Yogas" button to navigate to yoga screen
    - _Requirements: Integration with existing Panchang feature_
  
  - [ ]* 10.2 Write integration tests for Panchang screen
    - Test yoga section displays correctly
    - Test navigation to yoga screen
    - Test data consistency between Panchang and Yoga services
    - _Requirements: Validation of Panchang integration_


- [x] 11. Add navigation and routing
  - Add yoga screen routes to app router
  - Create navigation from home screen to yoga screen
  - Create navigation from Panchang screen to yoga screen
  - Add bottom navigation item or menu entry for yogas
  - _Requirements: App navigation integration_

- [x] 12. Implement caching and performance optimization
  - Add caching for yoga detection results (avoid recalculating same date)
  - Implement efficient batch processing for monthly/annual calculations
  - Add debouncing for date picker changes
  - Optimize yoga data repository lookups
  - _Requirements: Performance optimization_

- [x] 13. Add error handling and edge cases
  - Handle network errors when fetching Panchang data
  - Handle invalid dates and locations
  - Add fallback for missing yoga data
  - Display user-friendly error messages
  - Add retry mechanism for failed API calls
  - _Requirements: Robust error handling_

- [x] 14. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- The yoga detection engine relies on PanchangService for Tithi, Nakshatra, and Vara data
- All yoga combination tables are based on traditional Vedic astrology texts
- The feature integrates seamlessly with the existing Panchang screen
- Caching is important for performance when calculating monthly/annual special days
- Color coding: Green for auspicious yogas, Red for inauspicious yogas
- Purpose filtering allows users to find yogas suitable for specific activities
