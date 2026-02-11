import 'package:flutter/material.dart';
import 'package:kundali_chart/kundali_chart.dart';
import '../../../app/theme.dart';
import '../../chart/data/demo_chart_data.dart';

/// Interactive Kundali Chart with counter-based house selection
class InteractiveKundaliChart extends StatelessWidget {
  final List<List<String>>? houses;
  final int? selectedHouse;
  final int? ascendantSign;
  final Function(int)? onHouseChanged;

  const InteractiveKundaliChart({
    Key? key,
    this.houses,
    this.selectedHouse,
    this.ascendantSign,
    this.onHouseChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentHouse = selectedHouse ?? 1;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Kundali Chart Display
          Container(
            height: 350, // Increased height for better visibility
            decoration: BoxDecoration(
              color: const Color(0xFFF2E6D8), // Beige/Paper background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8D6E63), width: 2), // Brown border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // The Chart Lines & Planets
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: KundaliChart(
                    houses: houses ?? DemoChartData.toKundaliFormat(),
                    strokeColor: const Color(0xFF8D6E63), // Brown lines
                    lineWidth: 1.5,
                    paddingFactor: 0.85,
                    houseLabelStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037), // Dark brown for house numbers
                    ),
                    planetStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E), // Navy blue for planets
                      height: 1.2,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                    houseLabels: _getHouseLabels(),
                  ),
                ),
                
                // Central Chart Title & Details Overlay
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        color: const Color(0xFFF2E6D8).withOpacity(0.8), // Semi-transparent bg for text
                        child: const Text(
                          "Lagna Chart",
                          style: TextStyle(
                            color: Color(0xFFC62828), // Red title
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      /* 
                         We can add birth details here if passed to the widget.
                         For now, preserving clean look. 
                         If details are needed, we can add them to the constructor.
                      */
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // House Counter
          if (onHouseChanged != null) _buildHouseCounter(currentHouse),
          
          const SizedBox(height: 12),
          
          // Planets in Selected House
          _buildPlanetsInHouse(currentHouse),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHouseCounter(int currentHouse) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentCyan.withOpacity(0.2),
            AstroTheme.accentCyan.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              final newHouse = currentHouse > 1 ? currentHouse - 1 : 12;
              onHouseChanged?.call(newHouse);
            },
            style: IconButton.styleFrom(
              backgroundColor: AstroTheme.accentCyan.withOpacity(0.2),
              padding: const EdgeInsets.all(8),
            ),
            icon: const Icon(
              Icons.remove_circle_outline,
              color: AstroTheme.accentCyan,
              size: 24,
            ),
          ),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AstroTheme.accentCyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.4)),
            ),
            child: Text(
              'House $currentHouse',
              style: const TextStyle(
                color: AstroTheme.accentCyan,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () {
              final newHouse = currentHouse < 12 ? currentHouse + 1 : 1;
              onHouseChanged?.call(newHouse);
            },
            style: IconButton.styleFrom(
              backgroundColor: AstroTheme.accentCyan.withOpacity(0.2),
              padding: const EdgeInsets.all(8),
            ),
            icon: const Icon(
              Icons.add_circle_outline,
              color: AstroTheme.accentCyan,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetsInHouse(int house) {
    final houseData = houses ?? DemoChartData.toKundaliFormat();
    final planets = houseData[house - 1];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentGold.withOpacity(0.15),
            AstroTheme.accentGold.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstroTheme.accentGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: AstroTheme.accentGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Planets in House $house',
                style: const TextStyle(
                  color: AstroTheme.accentGold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (planets.isEmpty)
            Text(
              'No planets in this house',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: planets.map((planet) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AstroTheme.accentGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AstroTheme.accentGold.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getPlanetEmoji(planet),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getPlanetName(planet),
                        style: const TextStyle(
                          color: AstroTheme.accentGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _getPlanetEmoji(String symbol) {
    const emojiMap = {
      'Su': '☀️',
      'Mo': '🌙',
      'Ma': '♂️',
      'Me': '☿️',
      'Ju': '♃',
      'Ve': '♀️',
      'Sa': '♄',
      'Ra': '🐉',
      'Ke': '🐍',
    };
    return emojiMap[symbol] ?? symbol;
  }

  String _getPlanetName(String symbol) {
    const nameMap = {
      'Su': 'Sun',
      'Mo': 'Moon',
      'Ma': 'Mars',
      'Me': 'Mercury',
      'Ju': 'Jupiter',
      'Ve': 'Venus',
      'Sa': 'Saturn',
      'Ra': 'Rahu',
      'Ke': 'Ketu',
    };
    return nameMap[symbol] ?? symbol;
  }

  List<String> _getHouseLabels() {
    if (ascendantSign == null) {
      return [
        '1', '2', '3', '4',
        '5', '6', '7', '8',
        '9', '10', '11', '12'
      ];
    }
    
    // Calculate sign numbers for each house based on ascendant
    final labels = <String>[];
    for (int i = 0; i < 12; i++) {
      final signNumber = ((ascendantSign! - 1 + i) % 12) + 1;
      // Format: House/Sign (e.g., "1/11" = House 1, Sign 11)
      labels.add('${i + 1}/$signNumber');
    }
    
    return labels;
  }
}
