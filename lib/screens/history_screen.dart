import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../models/health_log_model.dart';
import '../utils/constants.dart';
import '../widgets/weight_chart.dart';
import '../widgets/bmi_chart.dart';

enum _HistoryFilter { week, month, all }

/// Statistics / History screen showing past health data.
class HistoryScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const HistoryScreen({super.key, this.onBackToDashboard});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryFilter _filter = _HistoryFilter.all;

  List<HealthLog> _filtered(List<HealthLog> logs) {
    final now = DateTime.now();
    switch (_filter) {
      case _HistoryFilter.week:
        final cutoff = now.subtract( Duration(days: 7));
        return logs.where((l) => l.date.isAfter(cutoff)).toList();
      case _HistoryFilter.month:
        final cutoff = now.subtract( Duration(days: 30));
        return logs.where((l) => l.date.isAfter(cutoff)).toList();
      case _HistoryFilter.all:
        return logs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, HealthProvider>(
      builder: (context, authProvider, healthProvider, _) {
        final logs = healthProvider.logs;
        final filteredLogs = _filtered(logs);

        return CustomScrollView(
          physics:  BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding:
                       EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      if (widget.onBackToDashboard != null)
                        GestureDetector(
                          onTap: widget.onBackToDashboard,
                          child: Container(
                            padding:  EdgeInsets.all(10),
                            margin:  EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset:  Offset(0, 2),
                                ),
                              ],
                            ),
                            child:  Icon(Icons.arrow_back_rounded,
                                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark)),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statistics',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                              ),
                            ),
                            Text(
                              'Your health journey 📊',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Weight Chart Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 20),
                child: _buildChartCard(
                  icon: Icons.show_chart_rounded,
                  color: AppConstants.primaryColor,
                  title: 'Weight Trend',
                  child: SizedBox(
                    height: 200,
                    child: logs.isEmpty
                        ? Center(
                            child: Text('No data yet',
                                style: GoogleFonts.poppins(
                                    color: AppConstants.textLight)))
                        : WeightChart(logs: logs),
                  ),
                ),
              ),
            ),
             SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── BMI Chart Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 20),
                child: _buildChartCard(
                  icon: Icons.monitor_heart_outlined,
                  color: AppConstants.bmiColor,
                  title: 'BMI Trend',
                  child: SizedBox(
                    height: 200,
                    child: logs.isEmpty
                        ? Center(
                            child: Text('No data yet',
                                style: GoogleFonts.poppins(
                                    color: AppConstants.textLight)))
                        : BmiChart(logs: logs),
                  ),
                ),
              ),
            ),
             SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Water Bar Chart ──
            SliverToBoxAdapter(
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 20),
                child: _buildChartCard(
                  icon: Icons.water_drop_outlined,
                  color: AppConstants.waterColor,
                  title: 'Water Intake',
                  child: SizedBox(
                    height: 120,
                    child: logs.isEmpty
                        ? Center(
                            child: Text('No data yet',
                                style: GoogleFonts.poppins(
                                    color: AppConstants.textLight)))
                        : _buildWaterBars(logs.take(7).toList()),
                  ),
                ),
              ),
            ),
             SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Filter chips + Recent Entries header ──
            SliverToBoxAdapter(
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent Entries',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                        ),
                      ),
                    ),
                    _buildFilterChip('Week', _HistoryFilter.week),
                     SizedBox(width: 6),
                    _buildFilterChip('Month', _HistoryFilter.month),
                     SizedBox(width: 6),
                    _buildFilterChip('All', _HistoryFilter.all),
                  ],
                ),
              ),
            ),
             SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Log entries ──
            if (filteredLogs.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding:  EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.insert_chart_outlined_rounded,
                            size: 48,
                            color:
                                AppConstants.textLight.withValues(alpha: 0.5)),
                         SizedBox(height: 12),
                        Text(
                          logs.isEmpty
                              ? 'No entries yet.\nStart tracking to see your history!'
                              : 'No entries in this period.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppConstants.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding:  EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final log = filteredLogs[index];
                      return Padding(
                        padding:  EdgeInsets.only(bottom: 10),
                        child:
                            _buildLogEntry(context, log, healthProvider),
                      );
                    },
                    childCount: filteredLogs.length,
                  ),
                ),
              ),
             SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, _HistoryFilter value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration:  Duration(milliseconds: 180),
        padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppConstants.primaryColor
              : AppConstants.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppConstants.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required IconData icon,
    required Color color,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding:  EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset:  Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:  EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
               SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                ),
              ),
            ],
          ),
           SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildWaterBars(List<HealthLog> logs) {
    final reversedLogs = logs.reversed.toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: reversedLogs.map((log) {
        final pct =
            (log.waterIntake / AppConstants.waterGoalLiters).clamp(0.0, 1.0);
        final label = '${log.date.day}/${log.date.month}';
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${log.waterIntake.toStringAsFixed(1)}L',
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppConstants.waterColor,
              ),
            ),
             SizedBox(height: 4),
            Container(
              width: 28,
              height: 80 * pct,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppConstants.waterColor,
                    AppConstants.waterColor.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
             SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: AppConstants.textLight,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLogEntry(
      BuildContext context, HealthLog log, HealthProvider provider) {
    final dateStr = '${log.date.day}/${log.date.month}/${log.date.year}';

    return Dismissible(
      key: Key(log.id ?? ''),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding:  EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppConstants.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child:  Icon(Icons.delete_rounded, color: AppConstants.errorColor),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            title: Text('Delete Entry',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            content: Text('Delete this entry?', style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style:
                        GoogleFonts.poppins(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete',
                    style:
                        GoogleFonts.poppins(color: AppConstants.errorColor)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => provider.deleteLog(log.id ?? '', log.userId),
      child: Container(
        padding:  EdgeInsets.all(14),
        decoration: BoxDecoration(color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset:  Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding:
                   EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dateStr,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
             SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${log.weight.toStringAsFixed(1)} kg · ${log.stepsCount} steps · ${log.mood}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                    ),
                  ),
                  Text(
                    'Sleep: ${log.sleepHours.toStringAsFixed(1)}h · Water: ${log.waterIntake.toStringAsFixed(1)}L · Energy: ${log.energyLevel}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
