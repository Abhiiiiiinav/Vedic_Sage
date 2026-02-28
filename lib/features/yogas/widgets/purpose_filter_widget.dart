import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/models/yoga_models.dart';

/// A widget that displays filter chips for yoga purposes
/// 
/// Allows users to filter yogas by selecting one or more purposes.
/// Includes an "All" option to show all yogas.
class PurposeFilterWidget extends StatefulWidget {
  /// Callback when filter selection changes
  final Function(List<YogaPurpose>) onFilterChanged;
  
  /// Initially selected purposes (empty means "All")
  final List<YogaPurpose> initialSelection;

  const PurposeFilterWidget({
    super.key,
    required this.onFilterChanged,
    this.initialSelection = const [],
  });

  @override
  State<PurposeFilterWidget> createState() => _PurposeFilterWidgetState();
}

class _PurposeFilterWidgetState extends State<PurposeFilterWidget> {
  late Set<YogaPurpose> _selectedPurposes;

  @override
  void initState() {
    super.initState();
    _selectedPurposes = Set.from(widget.initialSelection);
  }

  /// Toggle a purpose filter
  void _togglePurpose(YogaPurpose? purpose) {
    setState(() {
      if (purpose == null) {
        // "All" was tapped - clear all selections
        _selectedPurposes.clear();
      } else {
        // Toggle specific purpose
        if (_selectedPurposes.contains(purpose)) {
          _selectedPurposes.remove(purpose);
        } else {
          _selectedPurposes.add(purpose);
        }
      }
    });
    
    // Notify parent of filter change
    widget.onFilterChanged(_selectedPurposes.toList());
  }

  @override
  Widget build(BuildContext context) {
    final isAllSelected = _selectedPurposes.isEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // "All" filter chip
            _buildFilterChip(
              label: 'All',
              icon: Icons.grid_view,
              isSelected: isAllSelected,
              onTap: () => _togglePurpose(null),
              color: AstroTheme.accentGold,
            ),
            const SizedBox(width: 8),
            
            // Purpose filter chips
            ...YogaPurpose.values.map((purpose) {
              final isSelected = _selectedPurposes.contains(purpose);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  label: _getPurposeLabel(purpose),
                  icon: _getPurposeIcon(purpose),
                  isSelected: isSelected,
                  onTap: () => _togglePurpose(purpose),
                  color: _getPurposeColor(purpose),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Build a filter chip
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.15),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white.withOpacity(0.6),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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

  /// Get purpose icon
  IconData _getPurposeIcon(YogaPurpose purpose) {
    switch (purpose) {
      case YogaPurpose.marriage:
        return Icons.favorite;
      case YogaPurpose.business:
        return Icons.business_center;
      case YogaPurpose.education:
        return Icons.school;
      case YogaPurpose.travel:
        return Icons.flight;
      case YogaPurpose.spiritual:
        return Icons.self_improvement;
      case YogaPurpose.health:
        return Icons.health_and_safety;
    }
  }

  /// Get purpose color
  Color _getPurposeColor(YogaPurpose purpose) {
    switch (purpose) {
      case YogaPurpose.marriage:
        return Colors.pink;
      case YogaPurpose.business:
        return AstroTheme.accentGold;
      case YogaPurpose.education:
        return AstroTheme.accentCyan;
      case YogaPurpose.travel:
        return Colors.blue;
      case YogaPurpose.spiritual:
        return AstroTheme.accentPurple;
      case YogaPurpose.health:
        return Colors.green;
    }
  }
}
