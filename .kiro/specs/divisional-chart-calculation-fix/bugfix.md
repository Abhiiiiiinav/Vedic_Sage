# Bugfix Requirements Document

## Introduction

The divisional chart calculation system is not correctly calculating all divisional charts (D2-D60) from the D1 (birth/Rashi) chart. The system currently uses a generic formula for most divisional charts, but several chart types require specific Vedic astrology formulas that differ from the generic approach. This results in incorrect planetary positions in divisional charts, which affects astrological analysis accuracy.

The bug impacts all divisional charts except D1 (which is calculated correctly from API data), D2, D3, and D30 (which have special case implementations). Charts like D4, D7, D9, D10, D12, D16, D20, D24, D27, D40, D45, and D60 may be using incorrect formulas that don't match traditional Vedic astrology standards.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN calculating D4 (Chaturthamsa) chart THEN the system uses the generic vargaSign formula which may not follow the correct 1st/4th/7th/10th sign rule

1.2 WHEN calculating D7 (Saptamsa) chart THEN the system uses the generic vargaSign formula which may not account for different rules for odd/even signs

1.3 WHEN calculating D9 (Navamsa) chart THEN the system uses the generic vargaSign formula which may not correctly start from Aries/Capricorn/Libra/Cancer based on element

1.4 WHEN calculating D10 (Dasamsa) chart THEN the system uses the generic vargaSign formula which may not correctly count from same sign for odd signs and 9th sign for even signs

1.5 WHEN calculating D12 (Dwadasamsa) chart THEN the system uses the generic vargaSign formula which may not always start from the same sign

1.6 WHEN calculating D16 (Shodasamsa) chart THEN the system uses the generic vargaSign formula which may not account for movable/fixed/dual sign classification

1.7 WHEN calculating D20 (Vimshamsa) chart THEN the system uses the generic vargaSign formula which may not follow the correct spiritual life calculation rules

1.8 WHEN calculating D24 (Chaturvimshamsa) chart THEN the system uses the generic vargaSign formula which may not follow the correct education-related calculation rules

1.9 WHEN calculating D27 (Bhamsa) chart THEN the system uses the generic vargaSign formula which may not follow the correct strength/vitality calculation rules

1.10 WHEN calculating D40 (Khavedamsa) chart THEN the system uses the generic vargaSign formula which may not follow the correct maternal legacy calculation rules

1.11 WHEN calculating D45 (Akshavedamsa) chart THEN the system uses the generic vargaSign formula which may not follow the correct character analysis calculation rules

1.12 WHEN calculating D60 (Shashtiamsa) chart THEN the system uses the generic vargaSign formula which may not follow the correct karmic calculation rules with the required sensitivity

1.13 WHEN divisional charts are calculated with incorrect formulas THEN planetary positions may differ from established Vedic astrology software like Jagannatha Hora or Parashara's Light

1.14 WHEN users compare divisional chart results with reference software THEN they may find discrepancies in planetary positions across multiple divisional charts

### Expected Behavior (Correct)

2.1 WHEN calculating D4 (Chaturthamsa) chart THEN the system SHALL use 7°30' segments and apply the 1st/4th/7th/10th sign rule correctly

2.2 WHEN calculating D7 (Saptamsa) chart THEN the system SHALL use 4°17'8" segments and apply different counting rules for odd signs (count from same sign) versus even signs (count from 7th sign)

2.3 WHEN calculating D9 (Navamsa) chart THEN the system SHALL use 3°20' segments and start counting from Aries for fire signs, Capricorn for earth signs, Libra for air signs, and Cancer for water signs

2.4 WHEN calculating D10 (Dasamsa) chart THEN the system SHALL use 3° segments and count from the same sign for odd signs and from the 9th sign for even signs

2.5 WHEN calculating D12 (Dwadasamsa) chart THEN the system SHALL use 2°30' segments and always count from the same sign

2.6 WHEN calculating D16 (Shodasamsa) chart THEN the system SHALL use 1°52'30" segments and apply different rules based on whether the sign is movable, fixed, or dual

2.7 WHEN calculating D20 (Vimshamsa) chart THEN the system SHALL use 1°30' segments and apply the correct formula for spiritual life analysis

2.8 WHEN calculating D24 (Chaturvimshamsa) chart THEN the system SHALL use 1°15' segments and apply the correct formula for education analysis

2.9 WHEN calculating D27 (Bhamsa) chart THEN the system SHALL use 1°6'40" segments and apply the correct formula for strength/vitality analysis

2.10 WHEN calculating D40 (Khavedamsa) chart THEN the system SHALL use 0°45' segments and apply the correct formula for maternal legacy analysis

2.11 WHEN calculating D45 (Akshavedamsa) chart THEN the system SHALL use 0°40' segments and apply the correct formula for character analysis

2.12 WHEN calculating D60 (Shashtiamsa) chart THEN the system SHALL use 0°30' segments and apply the most sensitive formula for complete karmic analysis

2.13 WHEN all divisional charts are calculated THEN planetary positions SHALL match those produced by established Vedic astrology software using the same ayanamsha and birth data

2.14 WHEN users verify divisional chart calculations THEN all planetary positions SHALL be consistent with traditional Parashara formulas documented in classical texts

### Unchanged Behavior (Regression Prevention)

3.1 WHEN calculating D1 (Rashi/Birth) chart THEN the system SHALL CONTINUE TO use the direct planetary positions from the API without modification

3.2 WHEN calculating D2 (Hora) chart THEN the system SHALL CONTINUE TO use the existing horaSign function with 15° segments mapping to Cancer/Leo based on odd/even signs

3.3 WHEN calculating D3 (Drekkana) chart THEN the system SHALL CONTINUE TO use the existing drekkanaSign function with 10° segments using the 1st/5th/9th sign rule

3.4 WHEN calculating D30 (Trimsamsa) chart THEN the system SHALL CONTINUE TO use the existing trimsamsaSign function with unequal divisions and planetary ownership

3.5 WHEN extracting planetary degrees from D1 chart data THEN the system SHALL CONTINUE TO use the fullDegree values from the API planetary data

3.6 WHEN storing divisional chart results THEN the system SHALL CONTINUE TO use the existing data structure with ascendantSign, planetSigns, and division fields

3.7 WHEN displaying divisional charts in the UI THEN the system SHALL CONTINUE TO use the existing table format showing all 16 main divisional charts

3.8 WHEN calculating house positions from divisional chart signs THEN the system SHALL CONTINUE TO use angular distance from the divisional ascendant

3.9 WHEN normalizing planet names between full names and abbreviations THEN the system SHALL CONTINUE TO support both formats (e.g., "Sun" and "Su")

3.10 WHEN caching divisional chart calculations THEN the system SHALL CONTINUE TO cache based on birth data to avoid redundant calculations
