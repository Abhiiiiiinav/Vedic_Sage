import 'package:flutter/material.dart';

/// Animated streak counter widget — Duolingo-style fire icon with pulsing glow
/// when streak is at risk.
class StreakWidget extends StatefulWidget {
  final int streakDays;
  final bool isAtRisk;

  const StreakWidget({
    super.key,
    required this.streakDays,
    this.isAtRisk = false,
  });

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isAtRisk) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAtRisk && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isAtRisk && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streakColor = widget.streakDays > 0
        ? const Color(0xFFFF6B00)
        : Colors.white24;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: streakColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isAtRisk
                  ? streakColor.withOpacity(_glowAnimation.value)
                  : streakColor.withOpacity(0.3),
              width: widget.isAtRisk ? 2 : 1,
            ),
            boxShadow: widget.isAtRisk
                ? [
                    BoxShadow(
                      color: streakColor.withOpacity(_glowAnimation.value * 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: widget.isAtRisk ? _pulseAnimation.value : 1.0,
                child: Icon(
                  Icons.local_fire_department,
                  color: streakColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.streakDays}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: streakColor,
                    ),
                  ),
                  Text(
                    widget.isAtRisk ? 'AT RISK!' : 'day streak',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: widget.isAtRisk ? streakColor : Colors.white54,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Engagement banner widget for home screen nudges
class EngagementBannerWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const EngagementBannerWidget({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    this.onTap,
    this.onDismiss,
  });

  @override
  State<EngagementBannerWidget> createState() => _EngagementBannerWidgetState();
}

class _EngagementBannerWidgetState extends State<EngagementBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color.withOpacity(0.15),
                widget.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              if (widget.onDismiss != null)
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: const Icon(Icons.close, color: Colors.white38, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
