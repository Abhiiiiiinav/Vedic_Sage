import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final LinearGradient gradient;
  final double borderRadius;
  final EdgeInsets? padding;

  const GradientContainer({
    super.key,
    required this.child,
    required this.gradient,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
