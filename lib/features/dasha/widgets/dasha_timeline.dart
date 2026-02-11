import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/models/dasha_models.dart';
import '../../../core/astro/vimshottari_engine.dart';
import 'package:intl/intl.dart';

class DashaTimeline extends StatelessWidget {
  /// List of Mahadasha Maps (each map has 'lord', 'years', 'startDate', 'endDate' directly)
  final List<Map<String, dynamic>> mahadashas;
  
  /// Currently selected dasha (expected format: {'md': {...}, 'ad': {...}})
  final Map<String, dynamic>? currentDasha;
  
  /// Callback when a dasha is selected, passes {'md': mdMap, 'ad': adMap, ...} structure
  final Function(Map<String, dynamic>) onDashaSelected;

  const DashaTimeline({
    super.key,
    required this.mahadashas,
    this.currentDasha,
    required this.onDashaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mahadashas.length,
        itemBuilder: (context, index) {
          // Each entry in mahadashas IS the MD data directly
          final mdMap = mahadashas[index];
          final md = MahadashaModel.fromMap(mdMap);
          
          // Check if this is the currently selected one
          // currentDasha is in wrapped format: {'md': {...}}
          final isCurrent = currentDasha != null && 
              currentDasha!['md'] != null &&
              currentDasha!['md']['lord'] == md.lord;
          
          return GestureDetector(
            onTap: () {
              // Generate Antardashas for this MD to pass back
              final antardashas = VimshottariEngine.generateAntardashas(
                mdLord: md.lord,
                mdYears: md.years,
                mdStartDate: md.startDate,
              );
              
              // Wrap in the expected {'md': ..., 'ad': ...} format
              onDashaSelected({
                'md': mdMap,
                'ad': antardashas.isNotEmpty ? antardashas.first : {},
                'allAntardashas': antardashas,
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isCurrent 
                    ? AstroTheme.accentGold.withOpacity(0.2) 
                    : AstroTheme.cardBackground,
                border: Border.all(
                  color: isCurrent 
                      ? AstroTheme.accentGold 
                      : Colors.white.withOpacity(0.1),
                  width: isCurrent ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent 
                        ? AstroTheme.accentGold 
                        : Colors.white.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Text(
                        md.lord.substring(0, 2),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.black : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    md.fullName,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? AstroTheme.accentGold : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy').format(md.startDate),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
