import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/health_log_model.dart';
import '../utils/constants.dart';

/// Weekly BMI trend line chart.
class BmiChart extends StatelessWidget {
  final List<HealthLog> logs;

  const BmiChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Text(
          'No data yet',
          style: GoogleFonts.poppins(color: AppConstants.textLight),
        ),
      );
    }

    final recentLogs = logs.take(7).toList().reversed.toList();

    final spots = recentLogs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.bmi);
    }).toList();

    final bmis = recentLogs.map((l) => l.bmi).toList();
    final minBmi = bmis.reduce((a, b) => a < b ? a : b);
    final maxBmi = bmis.reduce((a, b) => a > b ? a : b);
    final padding = (maxBmi - minBmi) * 0.2 + 1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppConstants.textLight.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 5,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppConstants.textLight,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= recentLogs.length) {
                  return const SizedBox.shrink();
                }
                final date = recentLogs[idx].date;
                return Text(
                  '${date.day}/${date.month}',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppConstants.textLight,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (recentLogs.length - 1).toDouble(),
        minY: minBmi - padding,
        maxY: maxBmi + padding,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppConstants.bmiColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: AppConstants.bmiColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppConstants.bmiColor.withValues(alpha: 0.2),
                  AppConstants.bmiColor.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  'BMI ${spot.y.toStringAsFixed(1)}',
                  GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
