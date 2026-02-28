# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Fault Condition** - Divisional Charts Use Generic Formula Instead of Vedic Formulas
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists by comparing with reference software
  - **Scoped PBT Approach**: Use known birth chart data (Nov 22, 2003, 13:30, Mysore, India) to ensure reproducibility
  - Test that for divisional charts D4, D7, D9, D10, D12, D16, D20, D24, D27, D40, D45, D60, the current generic vargaSign formula produces different results than reference software (Jagannatha Hora/Parashara's Light)
  - Test specific cases from Fault Condition:
    - D9 (Navamsa): Sun at 239.45° (Scorpio, water sign) should start from Cancer, not Aries
    - D7 (Saptamsa): Moon at 167.23° (Virgo, even sign) should count from 7th sign, not same sign
    - D10 (Dasamsa): Mars at 321.15° (Aquarius, odd sign) should count from same sign with correct formula
    - D16 (Shodasamsa): Venus at 269.78° (Sagittarius, dual sign) should use dual sign starting point
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found: planetary positions that differ from reference software
  - Create a discrepancy matrix showing which charts/planets are incorrect
  - Mark task complete when test is written, run, and failures are documented
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 1.10, 1.11, 1.12, 1.13, 1.14_

- [ ] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Existing Chart Calculations Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy inputs (D1, D2, D3, D30)
  - Write property-based tests capturing observed behavior patterns from Preservation Requirements:
    - D1 (Rashi): Verify direct API planetary positions are used without modification
    - D2 (Hora): Verify horaSign function with 15° segments mapping to Cancer/Leo based on odd/even signs
    - D3 (Drekkana): Verify drekkanaSign function with 10° segments using 1st/5th/9th sign rule
    - D30 (Trimsamsa): Verify trimsamsaSign function with unequal divisions and planetary ownership
  - Test data structures remain unchanged (ascendantSign, planetSigns, division fields)
  - Test that buildAllVargas and _buildVargaData functions continue to work with same interfaces
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10_

- [ ] 3. Implement divisional chart formula fixes

  - [ ] 3.1 Add D4 (Chaturthamsa) formula function
    - Create chaturtamsaSign function with 7°30' segments
    - Implement 1st/4th/7th/10th sign rule: offsets [0, 3, 6, 9]
    - Formula: `((rashi + offsets[part]) % 12) + 1` where part = 0-3
    - _Bug_Condition: isBugCondition(input) where input.division = 4_
    - _Expected_Behavior: Uses 7°30' segments and applies 1st/4th/7th/10th sign rule correctly (Req 2.1)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.1_

  - [ ] 3.2 Add D7 (Saptamsa) formula function
    - Create saptamsaSign function with 4°17'8" segments (30° / 7)
    - Implement odd/even sign rule: odd signs count from same sign, even signs from 7th sign
    - Formula: startSign = isOdd ? rashi : (rashi + 6) % 12
    - _Bug_Condition: isBugCondition(input) where input.division = 7_
    - _Expected_Behavior: Uses 4°17'8" segments and applies different counting rules for odd vs even signs (Req 2.2)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.2_

  - [ ] 3.3 Add D9 (Navamsa) formula function
    - Create navamsaSign function with 3°20' segments (30° / 9)
    - Implement element-based starting points: Aries (fire), Capricorn (earth), Libra (air), Cancer (water)
    - Formula: startSigns = [0, 9, 6, 3] indexed by element (rashi % 4)
    - _Bug_Condition: isBugCondition(input) where input.division = 9_
    - _Expected_Behavior: Uses 3°20' segments and starts from Aries/Capricorn/Libra/Cancer based on element (Req 2.3)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.3_

  - [ ] 3.4 Add D10 (Dasamsa) formula function
    - Create dasamsaSign function with 3° segments (30° / 10)
    - Implement odd/even sign rule: odd signs from same sign, even signs from 9th sign
    - Formula: startSign = isOdd ? rashi : (rashi + 8) % 12
    - _Bug_Condition: isBugCondition(input) where input.division = 10_
    - _Expected_Behavior: Uses 3° segments and counts from same sign for odd, 9th sign for even (Req 2.4)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.4_

  - [ ] 3.5 Add D12 (Dwadasamsa) formula function
    - Create dwadasamsaSign function with 2°30' segments (30° / 12)
    - Implement simple progression from natal sign
    - Formula: ((rashi + part) % 12) + 1 where part = 0-11
    - _Bug_Condition: isBugCondition(input) where input.division = 12_
    - _Expected_Behavior: Uses 2°30' segments and always counts from same sign (Req 2.5)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.5_

  - [ ] 3.6 Add D16 (Shodasamsa) formula function
    - Create shodasamsaSign function with 1°52'30" segments (30° / 16)
    - Implement sign classification: movable (Aries), fixed (Leo), dual (Sagittarius)
    - Formula: startSigns = [0, 4, 8] indexed by classification (rashi % 3)
    - _Bug_Condition: isBugCondition(input) where input.division = 16_
    - _Expected_Behavior: Uses 1°52'30" segments and applies rules based on movable/fixed/dual classification (Req 2.6)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.6_

  - [ ] 3.7 Add D20 (Vimshamsa) formula function
    - Create vimsamsaSign function with 1°30' segments (30° / 20)
    - Implement sign classification: movable (Aries), fixed (Sagittarius), dual (Leo)
    - Formula: startSigns = [0, 8, 4] indexed by classification (rashi % 3)
    - _Bug_Condition: isBugCondition(input) where input.division = 20_
    - _Expected_Behavior: Uses 1°30' segments and applies correct formula for spiritual life analysis (Req 2.7)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.7_

  - [ ] 3.8 Add D24 (Chaturvimshamsa) formula function
    - Create chaturvimsamsaSign function with 1°15' segments (30° / 24)
    - Implement odd/even sign rule: odd signs start from Leo, even from Cancer
    - Formula: startSign = isOdd ? 4 : 3 (Leo or Cancer)
    - _Bug_Condition: isBugCondition(input) where input.division = 24_
    - _Expected_Behavior: Uses 1°15' segments and applies correct formula for education analysis (Req 2.8)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.8_

  - [ ] 3.9 Add D27 (Bhamsa) formula function
    - Create bhamsaSign function with 1°6'40" segments (30° / 27)
    - Implement element-based starting points: Aries (fire), Cancer (earth), Libra (air), Capricorn (water)
    - Formula: startSigns = [0, 3, 6, 9] indexed by element (rashi % 4)
    - _Bug_Condition: isBugCondition(input) where input.division = 27_
    - _Expected_Behavior: Uses 1°6'40" segments and applies correct formula for strength/vitality analysis (Req 2.9)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.9_

  - [ ] 3.10 Add D40 (Khavedamsa) formula function
    - Create khavedamsaSign function with 0°45' segments (30° / 40)
    - Implement sign classification: movable (Aries), fixed (Leo), dual (Sagittarius)
    - Formula: startSigns = [0, 4, 8] indexed by classification (rashi % 3)
    - _Bug_Condition: isBugCondition(input) where input.division = 40_
    - _Expected_Behavior: Uses 0°45' segments and applies correct formula for maternal legacy analysis (Req 2.10)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.10_

  - [ ] 3.11 Add D45 (Akshavedamsa) formula function
    - Create akshavedamsaSign function with 0°40' segments (30° / 45)
    - Implement sign classification: movable (Aries), fixed (Leo), dual (Sagittarius)
    - Formula: startSigns = [0, 4, 8] indexed by classification (rashi % 3)
    - _Bug_Condition: isBugCondition(input) where input.division = 45_
    - _Expected_Behavior: Uses 0°40' segments and applies correct formula for character analysis (Req 2.11)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.11_

  - [ ] 3.12 Add D60 (Shashtiamsa) formula function
    - Create shashtiamsaSign function with 0°30' segments (30° / 60)
    - Implement simple progression from natal sign (most sensitive division)
    - Formula: ((rashi + part) % 12) + 1 where part = 0-59
    - _Bug_Condition: isBugCondition(input) where input.division = 60_
    - _Expected_Behavior: Uses 0°30' segments and applies most sensitive formula for karmic analysis (Req 2.12)_
    - _Preservation: Does not affect D1, D2, D3, D30 calculations (Req 3.1-3.4)_
    - _Requirements: 2.12_

  - [ ] 3.13 Update computeVargaSign switch statement
    - Add case 4: return chaturtamsaSign(deg)
    - Add case 7: return saptamsaSign(deg)
    - Add case 9: return navamsaSign(deg)
    - Add case 10: return dasamsaSign(deg)
    - Add case 12: return dwadasamsaSign(deg)
    - Add case 16: return shodasamsaSign(deg)
    - Add case 20: return vimsamsaSign(deg)
    - Add case 24: return chaturvimsamsaSign(deg)
    - Add case 27: return bhamsaSign(deg)
    - Add case 40: return khavedamsaSign(deg)
    - Add case 45: return akshavedamsaSign(deg)
    - Add case 60: return shashtiamsaSign(deg)
    - Keep existing cases 2, 3, 30 unchanged
    - Keep default case with vargaSign fallback
    - _Bug_Condition: isBugCondition(input) where input.division IN [4,7,9,10,12,16,20,24,27,40,45,60]_
    - _Expected_Behavior: Routes each division to its specific Vedic formula function (Req 2.1-2.12)_
    - _Preservation: Existing D2, D3, D30 cases remain unchanged (Req 3.2-3.4)_
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 2.11, 2.12, 3.2, 3.3, 3.4_

  - [ ] 3.14 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Divisional Charts Match Reference Software
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - Verify all 12 affected divisional charts (D4, D7, D9, D10, D12, D16, D20, D24, D27, D40, D45, D60) now match reference software
    - Verify specific cases: D9 Sun position, D7 Moon position, D10 Mars position, D16 Venus position
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 2.11, 2.12, 2.13, 2.14_

  - [ ] 3.15 Verify preservation tests still pass
    - **Property 2: Preservation** - Existing Chart Calculations Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm D1, D2, D3, D30 calculations produce identical results to unfixed code
    - Confirm data structures remain unchanged
    - Confirm buildAllVargas and _buildVargaData functions work correctly
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10_

- [ ] 4. Checkpoint - Ensure all tests pass
  - Run complete test suite including exploration test and preservation tests
  - Verify all 12 new divisional chart formulas produce correct results
  - Verify D1, D2, D3, D30 continue to work correctly
  - Test with multiple birth charts to ensure fix works across different planetary configurations
  - Compare complete chart output with reference software (Jagannatha Hora) for validation
  - Ensure all tests pass, ask the user if questions arise
