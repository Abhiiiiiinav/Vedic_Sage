# Divisional Chart Calculation Fix - Bugfix Design

## Overview

The divisional chart calculation system currently uses a generic `vargaSign` formula for most divisional charts (D4, D7, D9, D10, D12, D16, D20, D24, D27, D40, D45, D60), but traditional Vedic astrology requires specific formulas for each chart type. This bug causes incorrect planetary positions in divisional charts, affecting astrological analysis accuracy. The fix will implement the correct Parashara formulas for each divisional chart type while preserving the existing correct implementations for D1, D2, D3, and D30.

The fix approach is surgical: replace the generic `vargaSign` function with specific formula implementations for each chart type, ensuring calculations match established Vedic astrology software like Jagannatha Hora and Parashara's Light.

## Glossary

- **Bug_Condition (C)**: The condition that triggers the bug - when calculating divisional charts D4, D7, D9, D10, D12, D16, D20, D24, D27, D40, D45, or D60 using the generic vargaSign formula instead of chart-specific Vedic formulas
- **Property (P)**: The desired behavior - each divisional chart should use its specific Parashara formula to calculate planetary positions that match reference software
- **Preservation**: Existing calculations for D1, D2, D3, and D30 that already use correct formulas must remain unchanged
- **vargaSign**: The generic formula currently used: `((rashi * division + vargaPart) % 12) + 1`
- **Parashara Formulas**: Traditional Vedic astrology calculation methods documented in Brihat Parashara Hora Shastra
- **Rashi**: The zodiac sign (0-11 zero-indexed, or 1-12 one-indexed)
- **Varga**: Divisional chart segment within a sign
- **Odd/Even Signs**: Odd signs are Aries, Gemini, Leo, Libra, Sagittarius, Aquarius (indices 0, 2, 4, 6, 8, 10); Even signs are Taurus, Cancer, Virgo, Scorpio, Capricorn, Pisces (indices 1, 3, 5, 7, 9, 11)
- **Movable Signs**: Aries, Cancer, Libra, Capricorn (cardinal signs)
- **Fixed Signs**: Taurus, Leo, Scorpio, Aquarius (fixed signs)
- **Dual Signs**: Gemini, Virgo, Sagittarius, Pisces (mutable signs)
- **Element Groups**: Fire (Aries, Leo, Sagittarius), Earth (Taurus, Virgo, Capricorn), Air (Gemini, Libra, Aquarius), Water (Cancer, Scorpio, Pisces)

## Bug Details

### Fault Condition

The bug manifests when calculating any of the 12 affected divisional charts (D4, D7, D9, D10, D12, D16, D20, D24, D27, D40, D45, D60). The `computeVargaSign` function in `accurate_kundali_engine.dart` uses a switch statement that defaults to the generic `vargaSign` formula for all divisions except D2, D3, and D30. This generic formula does not account for the specific rules required by traditional Vedic astrology for each chart type.

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type { degree: double, division: int }
  OUTPUT: boolean
  
  RETURN input.division IN [4, 7, 9, 10, 12, 16, 20, 24, 27, 40, 45, 60]
         AND computeVargaSign(input.degree, input.division) uses vargaSign(degree, division)
         AND NOT usesChartSpecificFormula(input.division)
END FUNCTION
```

### Examples

**Example 1: D9 (Navamsa) - Incorrect Element-Based Starting Point**
- Input: Sun at 239.45° (Scorpio 29.45°, water sign)
- Current (Generic): Calculates from Aries regardless of element
- Expected (Correct): Should start from Cancer for water signs
- Impact: Incorrect Navamsa position affects marriage and spiritual analysis

**Example 2: D7 (Saptamsa) - Missing Odd/Even Sign Rule**
- Input: Moon at 167.23° (Virgo 17.23°, even sign)
- Current (Generic): Counts from same sign
- Expected (Correct): Should count from 7th sign for even signs
- Impact: Incorrect children/progeny analysis

**Example 3: D10 (Dasamsa) - Wrong Counting Start for Even Signs**
- Input: Mars at 321.15° (Aquarius 21.15°, odd sign)
- Current (Generic): Uses simple division formula
- Expected (Correct): Odd signs count from same sign, even signs from 9th sign
- Impact: Incorrect career analysis

**Example 4: D16 (Shodasamsa) - Missing Movable/Fixed/Dual Classification**
- Input: Venus at 269.78° (Sagittarius 29.78°, dual sign)
- Current (Generic): Treats all signs the same
- Expected (Correct): Different rules for movable, fixed, and dual signs
- Impact: Incorrect vehicle/comfort analysis

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- D1 (Rashi) calculation must continue to use direct planetary positions from API without modification
- D2 (Hora) calculation must continue to use the existing `horaSign` function with 15° segments mapping to Cancer/Leo based on odd/even signs
- D3 (Drekkana) calculation must continue to use the existing `drekkanaSign` function with 10° segments using the 1st/5th/9th sign rule
- D30 (Trimsamsa) calculation must continue to use the existing `trimsamsaSign` function with unequal divisions and planetary ownership
- The `computeVargaSign` function signature and switch statement structure must remain unchanged
- All data structures for storing divisional chart results (ascendantSign, planetSigns, division fields) must remain unchanged
- The `buildAllVargas` and `_buildVargaData` functions must continue to work with the same interfaces

**Scope:**
All inputs that do NOT involve the 12 affected divisional charts (D4, D7, D9, D10, D12, D16, D20, D24, D27, D40, D45, D60) should be completely unaffected by this fix. This includes:
- D1 calculations (direct from API)
- D2 calculations (horaSign function)
- D3 calculations (drekkanaSign function)
- D30 calculations (trimsamsaSign function)
- All other chart calculation logic (ascendant, houses, nakshatras, dashas)
- UI display and data extraction logic

## Hypothesized Root Cause

Based on the bug description and code analysis, the root cause is clear:

1. **Incomplete Implementation**: The original developer implemented special case functions for D2, D3, and D30 (which have well-documented unique rules), but used a generic mathematical formula for the remaining charts, assuming it would work universally.

2. **Generic Formula Limitation**: The `vargaSign` function uses `((rashi * division + vargaPart) % 12) + 1`, which is mathematically correct for simple equal divisions but doesn't account for:
   - Odd/even sign distinctions (D7, D10)
   - Element-based starting points (D9)
   - Sign classification rules (D16 with movable/fixed/dual)
   - Complex counting patterns required by Parashara

3. **Missing Vedic Rules**: Each divisional chart in Vedic astrology has specific rules documented in classical texts. The generic formula ignores these traditional calculation methods.

4. **Default Case in Switch**: The `computeVargaSign` function's default case `return vargaSign(deg, division);` applies the generic formula to all unhandled divisions, perpetuating the error across 12 different chart types.

## Correctness Properties

Property 1: Fault Condition - Divisional Charts Use Correct Vedic Formulas

_For any_ planetary degree input where the divisional chart being calculated is one of D4, D7, D9, D10, D12, D16, D20, D24, D27, D40, D45, or D60, the fixed calculation function SHALL apply the specific Parashara formula for that chart type, producing planetary positions that match established Vedic astrology software (Jagannatha Hora, Parashara's Light) using the same ayanamsha and birth data.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 2.11, 2.12, 2.13, 2.14**

Property 2: Preservation - Existing Chart Calculations Unchanged

_For any_ planetary degree input where the divisional chart being calculated is D1, D2, D3, or D30, the fixed code SHALL produce exactly the same result as the original code, preserving the existing correct implementations for these chart types and all related calculation logic.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10**

## Fix Implementation

### Changes Required

**File**: `lib/core/astro/accurate_kundali_engine.dart`

**Function**: `computeVargaSign` (and new helper functions)

**Specific Changes**:

1. **Add D4 (Chaturthamsa) Function**:
   - Segment size: 7°30' (30° / 4)
   - Rule: Count in 1st, 4th, 7th, 10th signs from the natal sign
   - Formula: For segment index 0-3, use signs at offsets [0, 3, 6, 9]
   ```dart
   int chaturtamsaSign(double deg) {
     int rashi = (deg ~/ 30).toInt();
     double posInSign = deg % 30;
     int part = (posInSign / 7.5).floor(); // 0-3
     const offsets = [0, 3, 6, 9]; // 1st, 4th, 7th, 10th
     return ((rashi + offsets[part]) % 12) + 1;
   }
   ```

2. **Add D7 (Saptamsa) Function**:
   - Segment size: 4°17'8" (30° / 7)
   - Rule: Odd signs count from same sign, even signs count from 7th sign
   - Formula: Different starting points based on odd/even
   ```dart
   int saptamsaSign(double deg) {
     int rashi = (deg ~/ 30).toInt();
     bool isOdd = (rashi % 2 == 0); // Aries=0 is odd
     double posInSign = deg % 30;
     int part = (posInSign / (30.0 / 7)).floor(); // 0-6
     int startSign = isOdd ? rashi : (rashi + 6) % 12;
     return ((startSign + part) % 12) + 1;
   }
   ```

3. **Add D9 (Navamsa) Function**:
   - Segment size: 3°20' (30° / 9)
   - Rule: Start from Aries (fire), Capricorn (earth), Libra (air), Cancer (water)
   - Formula: Element-based starting point
   ```dart
   int navamsaSign(double deg) {
     int rashi = (deg ~/ 30).toInt();
     double posInSign = deg % 30;
     int part = (posInSign / (30.0 / 9)).floor(); // 0-8
     
     // Determine element and starting sign
     int element = rashi % 4; // 0=fire, 1=earth, 2=air, 3=water
     const startSigns = [0, 9, 6, 3]; // Aries, Capricorn, Libra, Cancer
     int startSign = startSigns[element];
     
     return ((startSign + part) % 12) + 1;
   }
   ```

4. **Add D10 (Dasamsa) Function**:
   - Segment size: 3° (30° / 10)
   - Rule: Odd signs count from same sign, even signs count from 9th sign
   - Formula: Similar to D7 but with 9th sign offset for even
   ```dart
   int dasamsaSign(double deg) {
     int rashi = (deg ~/ 30).toInt();
     bool isOdd = (rashi % 2 == 0); // Aries=0 is odd
     double posInSign = deg % 30;
     int part = (posInSign / 3.0).floor(); // 0-9
     int startSign = isOdd ? rashi : (rashi + 8) % 12;
     return ((startSign + part) % 12) + 1;
   }
   ```

5. **Add D12 (Dwadasamsa) Function**:
   - Segment size: 2°30' (30° / 12)
   - Rule: Count from the same sign
   - Formula: Simple progression from natal sign
   ```dart
   int dwadasamsaSign(double deg) {
     int rashi = (deg ~/ 30).toInt();
     double posInSign = deg % 30;
     int part = (posInSign / 2.5).floor(); // 0-11
     return ((rashi + part) % 12) + 1;
   }
   ```

6. **Add D16 (Shodasamsa) Function**:
   - Segment size: 1°52'30" (30° / 16)
   - Rule: Movable signs start from Aries, Fixed from Leo, Dual from Sagittarius
   - Formula: Classification-based starting point
   ```dart
   int shodasamsaSign(double deg) {
     int rashi = (deg ~/ 30).toInt();
     double posInSign = deg % 30;
     int part = (posInSign / (30.0 / 16)).floor(); // 0-15
     
     // Classify sign: movable (0,3,6,9), fixed (1,4,7,10), dual (2,5,8,11)
     int classification = rashi % 3; // 0=movable, 1=fixed, 2=dual
     const startSigns = [0, 4, 8]; // Aries, Leo, Sagittarius
     int startSign = startSigns[classification];
     
     return ((startSign + part) % 12) + 1;
   }
   ```

7. **Add D20 (Vimshamsa) Function**:
   - Segment size: 1°30' (30° / 20)
   - Rule: Movable signs start from Aries, Fixed from Sagittarius, Dual from Leo
   - Formula: Different starting points than D16
   ```dart
   int vimsamsaSign(double deg) {
     int rashi = (deg ~/ 30).toInt();
     double posInSign = deg % 30;
     int part = (posInSign / 1.5).floor(); // 0-19
     
     int classification = rashi % 3;
     const startSigns = [0, 8, 4]; // Aries, Sagittarius, Leo
     int startSign = startSigns[classification];
     
     return ((startSign + part) % 12) + 1;
   }
   ```

8. **Add D24 (Chaturvimshamsa) Function**:
   - Segment size: 1°15' (30° / 24)
   - Rule: Odd signs start from Leo, even signs start from Cancer
   - Formula: Odd/even distinction with specific starting signs
   ```dart
   int chaturvimsamsaSign(double deg) {
     int rashi = (deg ~/ 30).toInt();
     bool isOdd = (rashi % 2 == 0);
     double posInSign = deg % 30;
     int part = (posInSign / 1.25).floor(); // 0-23
     int startSign = isOdd ? 4 : 3; // Leo or Cancer
     return ((startSign + part) % 12) + 1;
   }
   ```

9. **Add D27 (Bhamsa) Function**:
   - Segment size: 1°6'40" (30° / 27)
   - Rule: Fire signs start from Aries, Earth from Cancer, Air from Libra, Water from Capricorn
   - Formula: Element-based with different starting points than D9
   ```dart
   int bhamsaSign(double deg) {
     int rashi = (deg ~/ 30).toInt();
     double posInSign = deg % 30;
     int part = (posInSign / (30.0 / 27)).floor(); // 0-26
     
     int element = rashi % 4;
     const startSigns = [0, 3, 6, 9]; // Aries, Cancer, Libra, Capricorn
     int startSign = startSigns[element];
     
     return ((startSign + part) % 12) + 1;
   }
   ```

10. **Add D40 (Khavedamsa) Function**:
    - Segment size: 0°45' (30° / 40)
    - Rule: Movable signs start from Aries, Fixed from Leo, Dual from Sagittarius
    - Formula: Same classification as D16
    ```dart
    int khavedamsaSign(double deg) {
      int rashi = (deg ~/ 30).toInt();
      double posInSign = deg % 30;
      int part = (posInSign / 0.75).floor(); // 0-39
      
      int classification = rashi % 3;
      const startSigns = [0, 4, 8];
      int startSign = startSigns[classification];
      
      return ((startSign + part) % 12) + 1;
    }
    ```

11. **Add D45 (Akshavedamsa) Function**:
    - Segment size: 0°40' (30° / 45)
    - Rule: Movable signs start from Aries, Fixed from Leo, Dual from Sagittarius
    - Formula: Same classification as D16 and D40
    ```dart
    int akshavedamsaSign(double deg) {
      int rashi = (deg ~/ 30).toInt();
      double posInSign = deg % 30;
      int part = (posInSign / (30.0 / 45)).floor(); // 0-44
      
      int classification = rashi % 3;
      const startSigns = [0, 4, 8];
      int startSign = startSigns[classification];
      
      return ((startSign + part) % 12) + 1;
    }
    ```

12. **Add D60 (Shashtiamsa) Function**:
    - Segment size: 0°30' (30° / 60)
    - Rule: Count from the same sign (most sensitive division)
    - Formula: Simple progression with 60 divisions
    ```dart
    int shashtiamsaSign(double deg) {
      int rashi = (deg ~/ 30).toInt();
      double posInSign = deg % 30;
      int part = (posInSign / 0.5).floor(); // 0-59
      return ((rashi + part) % 12) + 1;
    }
    ```

13. **Update computeVargaSign Switch Statement**:
    - Add cases for divisions 4, 7, 9, 10, 12, 16, 20, 24, 27, 40, 45, 60
    - Call the appropriate specific function for each
    - Keep existing cases for 2, 3, 30 unchanged
    - Remove or keep the generic vargaSign as fallback for any other divisions
    ```dart
    int computeVargaSign(double deg, int division) {
      switch (division) {
        case 2:
          return horaSign(deg);
        case 3:
          return drekkanaSign(deg);
        case 4:
          return chaturtamsaSign(deg);
        case 7:
          return saptamsaSign(deg);
        case 9:
          return navamsaSign(deg);
        case 10:
          return dasamsaSign(deg);
        case 12:
          return dwadasamsaSign(deg);
        case 16:
          return shodasamsaSign(deg);
        case 20:
          return vimsamsaSign(deg);
        case 24:
          return chaturvimsamsaSign(deg);
        case 27:
          return bhamsaSign(deg);
        case 30:
          return trimsamsaSign(deg);
        case 40:
          return khavedamsaSign(deg);
        case 45:
          return akshavedamsaSign(deg);
        case 60:
          return shashtiamsaSign(deg);
        default:
          return vargaSign(deg, division); // Fallback for other divisions
      }
    }
    ```

## Testing Strategy

### Validation Approach

The testing strategy follows a three-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code by comparing with reference software; second, verify the fix produces correct results matching reference software; third, ensure existing correct calculations remain unchanged.

### Exploratory Fault Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Compare current calculations with established Vedic astrology software (Jagannatha Hora or Parashara's Light) to confirm the root cause analysis.

**Test Plan**: Use a known birth chart with verified divisional chart positions from reference software. Calculate each affected divisional chart (D4, D7, D9, D10, D12, D16, D20, D24, D27, D40, D45, D60) using the UNFIXED code and compare planetary positions with reference software. Document discrepancies.

**Test Birth Data**:
```
Date: November 22, 2003
Time: 13:30 (1:30 PM)
Location: Mysore, India
Latitude: 12.2958° N
Longitude: 76.6394° E
Timezone: +5.5 (IST)
Ayanamsha: Lahiri
```

**Test Cases**:
1. **D9 (Navamsa) Verification**: Calculate Sun position in D9 (will fail on unfixed code)
   - Sun at 239.45° (Scorpio 29.45°, water sign)
   - Expected (from Jagannatha Hora): Should start from Cancer for water signs
   - Current (Generic): Likely incorrect starting point
   
2. **D7 (Saptamsa) Verification**: Calculate Moon position in D7 (will fail on unfixed code)
   - Moon at 167.23° (Virgo 17.23°, even sign)
   - Expected: Should count from 7th sign (Pisces) for even signs
   - Current: Likely counts from same sign
   
3. **D10 (Dasamsa) Verification**: Calculate Mars position in D10 (will fail on unfixed code)
   - Mars at 321.15° (Aquarius 21.15°, odd sign)
   - Expected: Should count from same sign for odd signs
   - Current: May use incorrect formula
   
4. **D16 (Shodasamsa) Verification**: Calculate Venus position in D16 (will fail on unfixed code)
   - Venus at 269.78° (Sagittarius 29.78°, dual sign)
   - Expected: Should start from Sagittarius for dual signs
   - Current: Likely ignores sign classification

5. **All 12 Charts Comparison**: Run complete comparison for all affected charts
   - Compare all 9 planets + ascendant in each of the 12 affected charts
   - Document every discrepancy between current and reference software
   - Create a discrepancy matrix showing which charts/planets are incorrect

**Expected Counterexamples**:
- Planetary positions in D4, D7, D9, D10, D12, D16, D20, D24, D27, D40, D45, D60 will differ from reference software
- Specific patterns: D7 and D10 will show incorrect positions for even signs, D9 will show incorrect element-based starting points, D16/D20/D40/D45 will show incorrect classification-based starting points
- The generic formula produces mathematically consistent but astrologically incorrect results

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds (calculating D4, D7, D9, D10, D12, D16, D20, D24, D27, D40, D45, D60), the fixed function produces the expected behavior (matches reference software).

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition(input) DO
  result := computeVargaSign_fixed(input.degree, input.division)
  referenceResult := getReferencePosition(input.degree, input.division)
  ASSERT result = referenceResult
END FOR
```

**Testing Approach**: Use the same test birth data and compare fixed calculations with reference software positions. Test each of the 12 affected divisional charts.

**Test Plan**: 
1. Implement all 12 specific formula functions
2. Update computeVargaSign switch statement
3. Recalculate all divisional charts for test birth data
4. Compare each planetary position with reference software
5. Verify 100% match for all affected charts

**Test Cases**:
1. **D9 Navamsa Correctness**: Verify all 9 planets + ascendant match reference software
2. **D7 Saptamsa Correctness**: Verify odd/even sign rule is applied correctly
3. **D10 Dasamsa Correctness**: Verify career chart matches reference
4. **D16 Shodasamsa Correctness**: Verify movable/fixed/dual classification works
5. **D4, D12, D20, D24, D27, D40, D45, D60 Correctness**: Verify all remaining charts match reference
6. **Edge Cases**: Test planets at 0°, 15°, 29°59' within signs to verify boundary handling

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold (calculating D1, D2, D3, D30, or any other chart logic), the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition(input) DO
  ASSERT computeVargaSign_original(input) = computeVargaSign_fixed(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because it generates many test cases automatically across the input domain and catches edge cases that manual unit tests might miss.

**Test Plan**: Observe behavior on UNFIXED code first for D1, D2, D3, D30 calculations, then write tests capturing that exact behavior and verify it continues after the fix.

**Test Cases**:
1. **D1 Preservation**: Verify D1 continues to use direct API planetary positions
   - Test that D1 ascendant and all planets match API data exactly
   - No varga calculation should be applied to D1
   
2. **D2 Hora Preservation**: Verify horaSign function continues to work correctly
   - Test odd signs: 0-15° → Leo, 15-30° → Cancer
   - Test even signs: 0-15° → Cancer, 15-30° → Leo
   - Compare before/after fix results
   
3. **D3 Drekkana Preservation**: Verify drekkanaSign function continues to work correctly
   - Test 0-10° → same sign
   - Test 10-20° → 5th from sign
   - Test 20-30° → 9th from sign
   - Compare before/after fix results
   
4. **D30 Trimsamsa Preservation**: Verify trimsamsaSign function continues to work correctly
   - Test odd sign planetary lord divisions
   - Test even sign planetary lord divisions
   - Compare before/after fix results
   
5. **Data Structure Preservation**: Verify all chart data structures remain unchanged
   - Test that buildAllVargas returns same structure format
   - Test that _buildVargaData returns same fields
   - Test that UI can display results without changes

6. **Other Calculations Preservation**: Verify unrelated calculations are unaffected
   - Test ascendant calculation (tropicalAscendant, siderealAsc)
   - Test house calculations (planetHouse function)
   - Test nakshatra calculations
   - Test dasha calculations

### Unit Tests

- Test each new divisional chart function independently with known degree inputs
- Test boundary conditions (0°, 15°, 30° transitions)
- Test odd/even sign distinctions for D7, D10, D24
- Test element-based starting points for D9, D27
- Test sign classification for D16, D20, D40, D45
- Test the updated computeVargaSign switch statement routes to correct functions
- Test that existing D2, D3, D30 functions are not called for wrong divisions

### Property-Based Tests

- Generate random planetary degrees (0-360°) and verify each divisional chart function produces valid sign numbers (1-12)
- Generate random birth charts and verify all divisional charts can be calculated without errors
- Test that for any degree input, the same degree always produces the same divisional sign (deterministic)
- Test that divisional signs progress logically as degrees increase within a sign
- Generate edge cases (degrees near sign boundaries) and verify correct handling
- Test preservation: for D1, D2, D3, D30, verify fixed code produces identical results to unfixed code across many random inputs

### Integration Tests

- Test complete chart generation with all 16 divisional charts using test birth data
- Compare complete chart output with reference software (Jagannatha Hora)
- Test that UI displays all divisional charts correctly after fix
- Test that divisional chart table shows correct planetary positions
- Test that varga debug panel (if present) shows correct calculation details
- Test chart caching: verify cached charts use new calculations after fix
- Test multiple birth charts to ensure fix works across different planetary configurations

