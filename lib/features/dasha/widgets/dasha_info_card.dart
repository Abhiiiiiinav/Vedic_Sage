import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/section_card.dart';
import 'package:intl/intl.dart';

class DashaInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final String lordName;
  final String durationLabel;
  final DateTime startDate;
  final DateTime endDate;
  final String remainingTimeLabel;

  const DashaInfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.lordName,
    required this.durationLabel,
    required this.startDate,
    required this.endDate,
    required this.remainingTimeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      icon: icon,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lordName,
                style: AstroTheme.headingMedium.copyWith(
                  color: accentColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  durationLabel,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDateRow('Started', startDate),
          _buildDateRow('Ends', endDate),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_bottom, color: accentColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  remainingTimeLabel,
                  style: AstroTheme.bodyLarge.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: AstroTheme.bodyMedium,
          ),
          Text(
            DateFormat('dd/MM/yyyy').format(date),
            style: AstroTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
