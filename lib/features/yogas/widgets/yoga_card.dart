import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/models/yoga_models.dart';

/// A reusable card widget for displaying a YogaResult
/// 
/// Displays yoga name with icon, description, significance,
/// applicable purposes, and uses color coding (green for auspicious,
/// red for inauspicious).
class YogaCard extends StatelessWidget {
  final YogaResult yoga;

  const YogaCard({
    super.key,
    required this.yoga,
  });

  @override
  Widget build(BuildContext context) {
    final color = yoga.isAuspicious ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(color),
          const SizedBox(height: 12),
          _buildDescription(),
          const SizedBox(height: 12),
          _buildPanchangInfo(),
          if (yoga.purposes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPurposes(),
          ],
        ],
      ),
    );
  }

  /// Build header with yoga name and icon
  Widget _buildHeader(Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            yoga.isAuspicious ? Icons.star : Icons.warning_amber,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            yoga.definition.name,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Build description text
  Widget _buildDescription() {
    return Text(
      yoga.definition.description,
      style: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 13,
        height: 1.4,
      ),
    );
  }

  /// Build panchang info chips (Tithi, Nakshatra, Vara)
  Widget _buildPanchangInfo() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildInfoChip('Tithi', yoga.tithi, AstroTheme.accentPurple),
        _buildInfoChip('Nakshatra', yoga.nakshatra, AstroTheme.accentCyan),
        _buildInfoChip('Vara', yoga.vara, AstroTheme.accentGold),
      ],
    );
  }

  /// Build info chip for panchang elements
  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build purposes chips
  Widget _buildPurposes() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: yoga.purposes.map((purpose) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getPurposeLabel(purpose),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Get purpose label
  String _getPurposeLabel(YogaPurpose purpose) {
    switch (purpose) {
      case YogaPurpose.marriage:
        return 'Marriage';
      case YogaPurpose.business:
        return 'Business';
      case YogaPurpose.education:
        return 'Education';
      case YogaPurpose.travel:
        return 'Travel';
      case YogaPurpose.spiritual:
        return 'Spiritual';
      case YogaPurpose.health:
        return 'Health';
    }
  }
}
