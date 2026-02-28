# Divisional Charts Accuracy Verification Guide

This guide helps you verify that all planetary positions in divisional charts are calculated correctly.

## Understanding the Data Sources

The app uses **three data sources** in priority order:

1. **Local Varga Calculations** (Most Accurate) ✅
   - Uses `accurate_kundali_engine.dart`
   - Implements correct Parashara formulas
   - Calculates from planetary degrees

2. **API Planetary Data** (For D1 only)
   - Direct positions from Free Astrology API
   - Used as reference for birth chart

3. **SVG Parsing** (Fallback only)
   - Only used if local calculations unavailable

## How to Verify Accuracy

### Method 1: Compare with Known Software

Use established Vedic astrology software as reference:
- **Jagannatha Hora** (Free, Windows)
- **Parashara's Light** (Commercial)
- **Kala** (Commercial)

#### Test Birth Data
```
Date: November 22, 2003
Time: 13:30 (1:30 PM)
Location: Mysore, India
Latitude: 12.2958° N
Longitude: 76.6394° E
Timezone: +5.5 (IST)
Ayanamsha: Lahiri
```

### Method 2: Verify Key Divisional Charts

#### D1 (Rasi - Birth Chart)
- Should match the API planetary data exactly
- Ascendant: Aquarius (~21°)
- Verify all 9 planets match

#### D9 (Navamsa - Marriage Chart)
- Most important divisional chart
- Each sign divided into 9 parts (3°20' each)
- Formula: `((sign * 9) + navamsa_part) % 12 + 1`

#### D2 (Hora - Wealth)
- Odd signs: 0-15° = Leo, 15-30° = Cancer
- Even signs: 0-15° = Cancer, 15-30° = Leo

#### D3 (Drekkana - Siblings)
- 0-10° = Same sign
- 10-20° = 5th from sign
- 20-30° = 9th from sign

### Method 3: Check Vargottama Planets

**Vargottama** = Planet in same sign in D1 and divisional chart

This is a powerful placement. Check if any planets are Vargottama in:
- D9 (Navamsa)
- D10 (Dasamsa)
- D12 (Dwadasamsa)

### Method 4: Verify Ascendant Progression

The Ascendant should change logically across divisions:
- D1: Base ascendant
- D2: Should be Leo or Cancer (Hora rule)
- D9: Should follow Navamsa progression
- Higher divisions: More rapid changes

## Common Issues to Check

### ❌ Wrong Calculations
- Planets in impossible signs (e.g., all in Aries)
- Ascendant not changing across divisions
- D1 not matching API data

### ✅ Correct Calculations
- D1 matches API planetary positions
- Divisional charts show logical progression
- Some planets may be Vargottama
- Ascendant changes according to division rules

## Debugging Tools

### Enable Debug Logging

Add this to your chart calculation screen:

```dart
void _debugPrintVargas() {
  final session = UserSession();
  final vargas = session.birthChart?['vargas'] as Map<String, dynamic>?;
  
  if (vargas != null) {
    print('═══ VARGA DEBUG ═══');
    vargas.forEach((division, data) {
      print('\n$division:');
      print('  Ascendant: ${data['ascendantSign']}');
      print('  Planets: ${data['planetSigns']}');
    });
  }
}
```

### Check Planetary Degrees

The source degrees determine divisional positions:

```dart
void _debugPrintDegrees() {
  final session = UserSession();
  final apiPlanets = session.birthChart?['apiPlanets'] as Map<String, dynamic>?;
  
  if (apiPlanets != null) {
    print('═══ PLANETARY DEGREES ═══');
    apiPlanets.forEach((planet, data) {
      if (data is Map) {
        final fullDegree = data['fullDegree'] ?? data['full_degree'];
        final sign = data['current_sign'] ?? data['sign_num'];
        print('$planet: $fullDegree° (Sign: $sign)');
      }
    });
  }
}
```

## Expected Results for Test Data

For the test birth data above, here are some expected results:

### D1 (Rasi)
- Ascendant: Aquarius (11)
- Sun: Scorpio (8)
- Moon: Virgo (6)
- Mars: Aquarius (11)

### D9 (Navamsa)
- Ascendant: Will vary based on exact degree
- Check that it's different from D1
- Verify using reference software

### D10 (Dasamsa - Career)
- Each sign divided into 10 parts (3° each)
- Important for career analysis

## Validation Checklist

- [ ] D1 matches API data exactly
- [ ] All 16 divisional charts load successfully
- [ ] Ascendant is present in all charts
- [ ] No planets showing as "—" (missing)
- [ ] Planetary positions match reference software
- [ ] Vargottama planets identified correctly
- [ ] No duplicate planets in same chart
- [ ] All signs are between 1-12 (Aries-Pisces)

## Reference Formulas

### Generic Varga Formula
```
varga_sign = ((rashi * division + varga_part) % 12) + 1

where:
  rashi = sign number (0-11)
  division = D-number (e.g., 9 for D9)
  varga_part = floor(position_in_sign / part_size)
  part_size = 30° / division
```

### Special Cases
- **D2**: Uses Hora rule (odd/even signs)
- **D3**: Uses Drekkana rule (10° divisions)
- **D30**: Uses Trimsamsa rule (lord-based)

## Troubleshooting

### Issue: All charts show same data
**Solution**: Check that `buildAllVargas()` is being called with correct planetary degrees

### Issue: Missing planets
**Solution**: Verify planet abbreviations match ('Su', 'Mo', 'Ma', etc.)

### Issue: Wrong ascendant
**Solution**: Check that ascendant degree is being passed correctly to varga calculations

## Additional Resources

- [Parashara's Hora Shastra](https://www.vedicastrologer.org/bphs/) - Original text
- [Jagannatha Hora Download](http://www.vedicastrologer.org/jh/) - Free software
- [Varga Charts Explained](https://www.astrosage.com/divisional-charts.asp) - Theory

## Support

If you find discrepancies:
1. Note the specific chart (D1, D9, etc.)
2. Note the planet showing incorrect position
3. Compare with reference software
4. Check the planetary degree in D1
5. Verify the varga calculation formula

---

**Last Updated**: 2024
**Version**: 1.0
