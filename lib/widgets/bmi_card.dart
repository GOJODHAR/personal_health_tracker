import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/bmi_calculator.dart';
import '../utils/constants.dart';
import 'dart:math' as math;

/// BMI card with circular progress indicator and wellness aesthetic.
class BmiCard extends StatelessWidget {
  final double bmi;

  const BmiCard({super.key, required this.bmi});

  @override
  Widget build(BuildContext context) {
    final category = BmiCalculator.getBmiCategory(bmi);
    final categoryColor = Color(BmiCalculator.getBmiCategoryColor(bmi));
    // BMI range: 10-40 → progress 0.0-1.0
    final progress = ((bmi - 10) / 30).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _BmiCirclePainter(
                progress: progress,
                color: categoryColor,
              ),
              child: Center(
                child: Text(
                  bmi.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.textDark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMI',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppConstants.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Body Mass Index',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppConstants.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: categoryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for a circular BMI arc.
class _BmiCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  _BmiCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background arc
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BmiCirclePainter old) =>
      old.progress != progress || old.color != color;
}
