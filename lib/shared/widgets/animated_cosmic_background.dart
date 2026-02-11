import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedCosmicBackground extends StatefulWidget {
  final Widget child;

  const AnimatedCosmicBackground({super.key, required this.child});

  @override
  State<AnimatedCosmicBackground> createState() => _AnimatedCosmicBackgroundState();
}

class _AnimatedCosmicBackgroundState extends State<AnimatedCosmicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value * 2 * pi;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(cos(t), sin(t)),
              end: Alignment(-cos(t), -sin(t)),
              colors: const [
                Color(0xFF0F1023),
                Color(0xFF1A1C3A),
                Color(0xFF2A1B4D),
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
