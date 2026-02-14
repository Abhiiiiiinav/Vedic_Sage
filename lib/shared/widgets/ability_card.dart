import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/models/gamification_models.dart';

/// Ability card widget showing locked/unlocked personality insight abilities.
/// Locked: shows silhouette with "Complete X to unlock"
/// Unlocked: glowing icon + personality reveal
class AbilityCard extends StatefulWidget {
  final Ability ability;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AbilityCard({
    super.key,
    required this.ability,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  State<AbilityCard> createState() => _AbilityCardState();
}

class _AbilityCardState extends State<AbilityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.isUnlocked) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? (widget.isUnlocked ? () => _showAbilityDetail(context) : null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isUnlocked
              ? AstroTheme.accentPurple.withOpacity(0.15)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isUnlocked
                ? AstroTheme.accentPurple.withOpacity(0.4)
                : Colors.white.withOpacity(0.05),
            width: widget.isUnlocked ? 1.5 : 1,
          ),
          boxShadow: widget.isUnlocked
              ? [
                  BoxShadow(
                    color: AstroTheme.accentPurple.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon area
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isUnlocked
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AstroTheme.accentPurple,
                              AstroTheme.accentCyan,
                            ],
                          )
                        : null,
                    color: widget.isUnlocked ? null : Colors.white.withOpacity(0.05),
                  ),
                  child: Center(
                    child: widget.isUnlocked
                        ? Text(
                            widget.ability.icon,
                            style: const TextStyle(fontSize: 24),
                          )
                        : const Icon(
                            Icons.lock_outline,
                            color: Colors.white24,
                            size: 22,
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              widget.ability.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.isUnlocked ? Colors.white : Colors.white38,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Status
            Text(
              widget.isUnlocked ? 'UNLOCKED' : 'LOCKED',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: widget.isUnlocked
                    ? AstroTheme.accentGold
                    : Colors.white12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbilityDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AstroTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AstroTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AstroTheme.accentPurple.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.ability.icon,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.ability.title,
              style: AstroTheme.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.ability.description,
              style: AstroTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Personality Reveal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AstroTheme.accentPurple.withOpacity(0.1),
                    AstroTheme.accentCyan.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AstroTheme.accentPurple.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Personality Insight',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ability.personalityReveal,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
