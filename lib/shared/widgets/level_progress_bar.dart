import 'package:flutter/material.dart';
import '../../app/theme.dart';

class LevelProgressBar extends StatelessWidget {
  final int currentLevel;
  final int currentXP;
  final int xpForNextLevel;
  final bool showDetails;
  final double height;

  const LevelProgressBar({
    super.key,
    required this.currentLevel,
    required this.currentXP,
    required this.xpForNextLevel,
    this.showDetails = true,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentXP / xpForNextLevel;
    final nextLevel = currentLevel + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDetails) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $currentLevel',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$currentXP / $xpForNextLevel XP',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Stack(
          children: [
            // Background
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Progress
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AstroTheme.accentCyan,
                      AstroTheme.accentPurple,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: AstroTheme.accentPurple.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showDetails) ...[
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% to Level $nextLevel',
            style: TextStyle(
              color: AstroTheme.accentCyan,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
