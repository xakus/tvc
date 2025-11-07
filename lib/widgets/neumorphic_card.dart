import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/utils.dart';
import '../theme/app_colors.dart';

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  late  double borderRadius;
  final double borderWidth;
  final bool center;

  NeumorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(0),
    this.borderWidth = 3,
    this.center =true,
  });

  @override
  Widget build(BuildContext context) {
    borderRadius =  Utils.getHeightSize(context, 10);
    return CustomPaint(
      painter: GradientBorderPainter(
        gradient: const LinearGradient(
          colors: [
            AppColors.borderGradientBlue,
            AppColors.borderGradientPurple,
          ],
        ),
        borderRadius: borderRadius,
        borderWidth: borderWidth,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: center ? Center(child: child) :Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(alignment: Alignment.centerLeft,child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double borderRadius;
  final double borderWidth;

  GradientBorderPainter({
    required this.gradient,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
