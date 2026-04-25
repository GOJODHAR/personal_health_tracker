import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// Water intake progress with glass icons filling up.
class WaterProgress extends StatelessWidget {
  final double currentIntake;

  const WaterProgress({super.key, required this.currentIntake});

  @override
  Widget build(BuildContext context) {
    final progress =
        (currentIntake / AppConstants.waterGoalLiters).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();
    const glassesTotal = 8; // 8 glasses = ~3L
    final glassesFilled =
        ((currentIntake / AppConstants.waterGoalLiters) * glassesTotal)
            .round()
            .clamp(0, glassesTotal);

    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.waterColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: AppConstants.waterColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Water Intake',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textDark,
                        ),
                      ),
                      Text(
                        '${currentIntake.toStringAsFixed(1)} / ${AppConstants.waterGoalLiters.toStringAsFixed(1)} L',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppConstants.textMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Percentage badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.waterColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percentage%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.waterColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Glass icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(glassesTotal, (i) {
              final filled = i < glassesFilled;
              return Column(
                children: [
                  Icon(
                    filled
                        ? Icons.local_drink_rounded
                        : Icons.local_drink_outlined,
                    color: filled
                        ? AppConstants.waterColor
                        : AppConstants.textLight.withValues(alpha: 0.4),
                    size: 24,
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppConstants.waterColor.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppConstants.waterColor),
            ),
          ),
        ],
      ),
    );
  }
}
