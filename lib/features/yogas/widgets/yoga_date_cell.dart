import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/models/yoga_models.dart';

/// A reusable calendar date cell widget that displays yoga indicators
/// 
/// This widget shows:
/// - Date number
/// - Colored dots for auspicious (green) and inauspicious (red) yogas
/// - Yoga count badge
/// - Visual states for today, selected, and dates with yogas
/// - Tap handling to show full yoga details
class YogaDateCell extends StatelessWidget {
  /// The date to display
  final DateTime date;
  
  /// List of yogas active on this date (null if not loaded, empty if no yogas)
  final List<YogaResult>? yogas;
  
  /// Whether this date is currently selected
  final bool isSelected;
  
  /// Whether this date is today
  final bool isToday;
  
  /// Callback when the date cell is tapped
  final VoidCallback? onTap;

  const YogaDateCell({
    super.key,
    required this.date,
    required this.yogas,
    this.isSelected = false,
    this.isToday = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasYogas = yogas != null && yogas!.isNotEmpty;
    final auspiciousCount = yogas?.where((y) => y.isAuspicious).length ?? 0;
    final inauspiciousCount = yogas?.where((y) => !y.isAuspicious).length ?? 0;

    return GestureDetector(
      onTap: hasYogas ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(hasYogas),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(),
            width: isToday || isSelected ? 2 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDateNumber(hasYogas),
            if (hasYogas) ...[
              const SizedBox(height: 4),
              _buildYogaIndicators(auspiciousCount, inauspiciousCount),
              const SizedBox(height: 2),
              _buildYogaCountBadge(),
            ],
          ],
        ),
      ),
    );
  }

  /// Get background color based on cell state
  Color _getBackgroundColor(bool hasYogas) {
    if (isSelected) {
      return AstroTheme.accentGold.withOpacity(0.3);
    }
    if (hasYogas) {
      return AstroTheme.cardBackground.withOpacity(0.5);
    }
    return Colors.transparent;
  }

  /// Get border color based on cell state
  Color _getBorderColor() {
    if (isToday) {
      return AstroTheme.accentCyan;
    }
    if (isSelected) {
      return AstroTheme.accentGold;
    }
    return Colors.transparent;
  }

  /// Build the date number text
  Widget _buildDateNumber(bool hasYogas) {
    return Text(
      date.day.toString(),
      style: TextStyle(
        color: hasYogas ? Colors.white : Colors.white.withOpacity(0.3),
        fontSize: 14,
        fontWeight: hasYogas ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Build colored dots indicating auspicious/inauspicious yogas
  Widget _buildYogaIndicators(int auspiciousCount, int inauspiciousCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (auspiciousCount > 0)
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        if (auspiciousCount > 0 && inauspiciousCount > 0)
          const SizedBox(width: 2),
        if (inauspiciousCount > 0)
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  /// Build the yoga count badge
  Widget _buildYogaCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AstroTheme.accentGold.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        yogas!.length.toString(),
        style: const TextStyle(
          color: AstroTheme.accentGold,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
