# How to Test Divisional Charts Accuracy

## Quick Test Steps

### 1. Open the App
The app is now running on Chrome at: http://127.0.0.1:41244/8S0DAS739QY=

### 2. Navigate to Divisional Charts Table
1. Calculate or load a birth chart
2. Go to the Divisional Charts Table screen
3. You should see a table with:
   - **First row**: Ascendant (🔺) with gold color
   - **Next 9 rows**: Planets (Sun through Ketu)
   - **16 columns**: One for each divisional chart (D1-D60)

### 3. Access Debug Panel
Look for the **bug icon** (🐛) in the top-right corner of the screen.
- This button only appears in debug mode
- Click it to open the Varga Debug Panel

### 4. Verify in Debug Panel

The debug panel shows:

#### 📐 Planetary Degrees Section
- Shows the source degrees for each planet
- Example: `Sun: 239.45° (Sign: 8, 29.45° in sign)`
- These are the raw values used for all calculations

#### 🔢 Varga Calculations Section
- Expandable tiles for each division (D1, D2, D3, D9, D10, D12)
- Shows calculated sign for each planet
- Shows the source degree used
- Example: `Sun: Scorpio (8) ← 239.45°`

#### ⭐ Vargottama Planets Section
- Lists planets that are in the same sign in D1 and D9
- This is a powerful placement in Vedic astrology
- Example: `Mars in Aquarius (D9)` means Mars is Vargottama

### 5. Manual Verification Steps

#### Check D1 (Birth Chart)
1. Look at the first column (D1)
2. All planets should have values (no "—")
3. Compare with the "Planetary Degrees" in debug panel
4. The sign should match: 
   - 0-30° = Aries (1)
   - 30-60° = Taurus (2)
   - etc.

#### Check D9 (Navamsa)
1. Look at the D9 column
2. Planets should be in different signs than D1 (usually)
3. Each 30° sign is divided into 9 parts of 3°20' each
4. Verify using the formula in debug panel

#### Check D2 (Hora)
1. Should only show Leo (5) or Cancer (4)
2. Odd signs (Aries, Gemini, Leo, etc.):
   - 0-15° → Leo
   - 15-30° → Cancer
3. Even signs (Taurus, Cancer, Virgo, etc.):
   - 0-15° → Cancer
   - 15-30° → Leo

### 6. Compare with Reference Software

#### Using Jagannatha Hora (Free)
1. Download from: http://www.vedicastrologer.org/jh/
2. Enter the same birth data
3. Go to View → Varga Charts
4. Compare each divisional chart

#### Test Birth Data
```
Name: Abhinav (or your test data)
Date: November 22, 2003
Time: 13:30 (1:30 PM)
Place: Mysore, India
Latitude: 12.2958° N
Longitude: 76.6394° E
Timezone: +5.5 (IST)
Ayanamsha: Lahiri
```

### 7. What to Look For

#### ✅ Correct Calculations
- [ ] All 16 divisional charts load
- [ ] Ascendant row shows values for all charts
- [ ] All 9 planets show values (no missing data)
- [ ] D1 matches the planetary degrees
- [ ] D2 only shows Leo/Cancer
- [ ] D9 shows logical progression
- [ ] Some planets may be Vargottama

#### ❌ Incorrect Calculations
- [ ] Missing planets (showing "—")
- [ ] All planets in same sign
- [ ] D1 doesn't match source degrees
- [ ] Ascendant not changing across divisions
- [ ] Signs outside 1-12 range

### 8. Common Test Cases

#### Test Case 1: Verify D1 Accuracy
```
Expected: D1 should exactly match the API planetary data
How to verify: 
1. Check debug panel "Planetary Degrees"
2. Calculate sign: floor(degree / 30) + 1
3. Compare with D1 column in table
```

#### Test Case 2: Verify D9 Navamsa
```
Expected: Each sign divided into 9 parts
Formula: ((sign * 9) + navamsa_part) % 12 + 1
How to verify:
1. Take planet degree from debug panel
2. Calculate: position_in_sign = degree % 30
3. Calculate: navamsa_part = floor(position_in_sign / 3.333)
4. Apply formula
5. Compare with D9 column
```

#### Test Case 3: Verify Vargottama
```
Expected: Some planets may be in same sign in D1 and D9
How to verify:
1. Check debug panel "Vargottama Planets" section
2. Verify those planets show same sign in D1 and D9 columns
3. This is a rare and powerful placement
```

### 9. Troubleshooting

#### Issue: Debug button not visible
**Solution**: Make sure you're running in debug mode (not release mode)

#### Issue: No data in debug panel
**Solution**: 
1. Make sure you've calculated a birth chart first
2. Check that the chart data is saved in session
3. Try refreshing the divisional charts screen

#### Issue: Values don't match reference software
**Solution**:
1. Verify you're using the same ayanamsha (Lahiri)
2. Check the exact birth time (even 1 minute can change results)
3. Verify timezone is correct
4. Check if reference software uses different calculation method

### 10. Expected Results for Test Data

For birth data: Nov 22, 2003, 13:30, Mysore

#### D1 (Rasi)
- Ascendant: Aquarius (11)
- Sun: Scorpio (8) - around 29°
- Moon: Virgo (6)
- Mars: Aquarius (11)
- Mercury: Scorpio (8)
- Jupiter: Leo (5)
- Venus: Sagittarius (9)
- Saturn: Gemini (3)
- Rahu: Aries (1)
- Ketu: Libra (7)

#### D9 (Navamsa)
- Will vary based on exact degrees
- Check against reference software
- Some planets may be Vargottama

### 11. Performance Test

- [ ] All 16 charts load within 2 seconds
- [ ] No lag when scrolling the table
- [ ] Debug panel opens instantly
- [ ] Refresh works smoothly

### 12. Edge Cases to Test

1. **Birth at midnight (00:00)**
   - Verify ascendant calculation
   
2. **Birth at sign boundary**
   - E.g., 29°59' of a sign
   - Check if rounding is correct

3. **Retrograde planets**
   - Verify they still calculate correctly
   - Retrograde doesn't affect sign position

4. **Southern hemisphere birth**
   - Use negative latitude
   - Verify calculations still work

## Summary

The divisional charts are now using the **accurate_kundali_engine.dart** which implements correct Parashara formulas. The debug panel helps you verify:

1. Source planetary degrees are correct
2. Varga calculations follow proper formulas
3. Results match reference software
4. Vargottama planets are identified

If you find any discrepancies, note:
- Which chart (D1, D9, etc.)
- Which planet
- Expected vs actual sign
- Source degree from debug panel

---

**App URL**: http://127.0.0.1:41244/8S0DAS739QY=
**Debug Mode**: Enabled (bug icon visible)
**Last Updated**: 2024
