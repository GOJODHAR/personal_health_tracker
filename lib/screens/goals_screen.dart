import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/goal_model.dart';
import '../models/health_log_model.dart';
import '../providers/auth_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';

class GoalsScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const GoalsScreen({super.key, this.onBackToDashboard});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late TextEditingController _weightController;
  late TextEditingController _waterController;
  late TextEditingController _stepsController;
  late TextEditingController _sleepController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _waterController = TextEditingController();
    _stepsController = TextEditingController();
    _sleepController = TextEditingController();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final userId =
        Provider.of<AuthProvider>(context, listen: false).currentUserId;
    if (userId != null) {
      await Provider.of<GoalProvider>(context, listen: false)
          .fetchGoals(userId);
      _syncControllers();
    }
  }

  void _syncControllers() {
    final goals =
        Provider.of<GoalProvider>(context, listen: false).goals;
    if (goals != null) {
      _weightController.text = goals.targetWeight.toStringAsFixed(1);
      _waterController.text = goals.dailyWaterGoal.toStringAsFixed(1);
      _stepsController.text = '${goals.stepGoal}';
      _sleepController.text = goals.sleepGoal.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waterController.dispose();
    _stepsController.dispose();
    _sleepController.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    final userId =
        Provider.of<AuthProvider>(context, listen: false).currentUserId;
    if (userId == null) return;

    final goalProvider =
        Provider.of<GoalProvider>(context, listen: false);
    final updatedGoals = GoalModel(
      userId: userId,
      targetWeight:
          double.tryParse(_weightController.text.trim()) ?? 65.0,
      dailyWaterGoal:
          double.tryParse(_waterController.text.trim()) ?? 3.0,
      stepGoal: int.tryParse(_stepsController.text.trim()) ?? 10000,
      sleepGoal:
          double.tryParse(_sleepController.text.trim()) ?? 8.0,
    );

    final success = await goalProvider.saveGoals(updatedGoals);
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_rounded
                    : Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
               SizedBox(width: 10),
              Text(
                success ? 'Goals updated! 🎯' : 'Failed to save goals',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
          backgroundColor: success
              ? AppConstants.primaryColor
              : AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, GoalProvider, HealthProvider>(
      builder: (context, authProvider, goalProvider, healthProvider, _) {
        final goals = goalProvider.goals;
        final latestLog = healthProvider.latestLog;

        return SafeArea(
          child: SingleChildScrollView(
            physics:  BouncingScrollPhysics(),
            padding:  EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
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
                                color:
                                    Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset:  Offset(0, 2),
                              ),
                            ],
                          ),
                          child:  Icon(Icons.arrow_back_rounded,
                              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark), size: 20),
                        ),
                      ),
                     Icon(Icons.flag_rounded,
                        color: AppConstants.primaryColor, size: 24),
                     SizedBox(width: 8),
                    Text(
                      'My Goals',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                      ),
                    ),
                     Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() => _isEditing = !_isEditing);
                        if (!_isEditing) _syncControllers();
                      },
                      child: Container(
                        padding:  EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isEditing
                              ? AppConstants.primaryColor
                                  .withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppConstants.primaryColor
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _isEditing ? 'Cancel' : 'Edit',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                 SizedBox(height: 8),
                Text(
                  'Set your targets and track your progress',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                  ),
                ),
                 SizedBox(height: 24),

                // ── Progress Messages (show only when not editing) ──
                if (!_isEditing && goals != null && latestLog != null) ...[
                  _buildProgressBanner(goals, latestLog),
                   SizedBox(height: 20),
                ],

                // ── Goal Cards ──
                if (goals == null)
                  Center(
                    child: Padding(
                      padding:  EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                           CircularProgressIndicator(
                              color: AppConstants.primaryColor),
                           SizedBox(height: 12),
                          Text('Loading goals...',
                              style: GoogleFonts.poppins(
                                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium))),
                        ],
                      ),
                    ),
                  )
                else ...[
                  _buildGoalCard(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Target Weight',
                    controller: _weightController,
                    unit: 'kg',
                    color: AppConstants.weightColor,
                    currentValue: latestLog?.weight,
                    goalValue: goals.targetWeight,
                    enabled: _isEditing,
                    startValue: (authProvider.user?.weightKg != null && authProvider.user!.weightKg > 0)
                        ? authProvider.user!.weightKg
                        : (healthProvider.logs.isNotEmpty 
                            ? healthProvider.logs.last.weight 
                            : null),
                  ),
                   SizedBox(height: 14),
                  _buildGoalCard(
                    icon: Icons.water_drop_outlined,
                    title: 'Daily Water Goal',
                    controller: _waterController,
                    unit: 'liters',
                    color: AppConstants.waterColor,
                    currentValue: latestLog?.waterIntake,
                    goalValue: goals.dailyWaterGoal,
                    enabled: _isEditing,
                  ),
                   SizedBox(height: 14),
                  _buildGoalCard(
                    icon: Icons.directions_walk_rounded,
                    title: 'Daily Step Goal',
                    controller: _stepsController,
                    unit: 'steps',
                    color: AppConstants.stepsColor,
                    currentValue: latestLog?.stepsCount.toDouble(),
                    goalValue: goals.stepGoal.toDouble(),
                    enabled: _isEditing,
                    isInteger: true,
                  ),
                   SizedBox(height: 14),
                  _buildGoalCard(
                    icon: Icons.bedtime_outlined,
                    title: 'Sleep Goal',
                    controller: _sleepController,
                    unit: 'hours',
                    color: AppConstants.sleepColor,
                    currentValue: latestLog?.sleepHours,
                    goalValue: goals.sleepGoal,
                    enabled: _isEditing,
                  ),
                   SizedBox(height: 28),

                  // ── Save Button ──
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient:  LinearGradient(
                            colors: [
                              AppConstants.gradientStart,
                              AppConstants.gradientEnd,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.primaryColor
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset:  Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed:
                              goalProvider.isLoading ? null : _saveGoals,
                          icon: goalProvider.isLoading
                              ?  SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              :  Icon(Icons.flag_rounded, size: 20),
                          label: Text(
                            goalProvider.isLoading
                                ? 'Saving...'
                                : 'Save Goals',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding:
                                 EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // PROGRESS BANNER
  // ──────────────────────────────────────────────

  Widget _buildProgressBanner(GoalModel goals, HealthLog latestLog) {
    final messages = <_ProgressMessage>[];

    // Weight progress
    final weightDiff =
        (latestLog.weight - goals.targetWeight).abs();
    if (latestLog.weight > goals.targetWeight) {
      messages.add(_ProgressMessage(
        '${weightDiff.toStringAsFixed(1)} kg to reach your goal 💙',
        AppConstants.weightColor,
        Icons.monitor_weight_outlined,
      ));
    } else {
      messages.add(_ProgressMessage(
        'You hit your weight goal! 🎉',
        AppConstants.primaryColor,
        Icons.emoji_events_rounded,
      ));
    }

    // Water progress
    final waterPct =
        ((latestLog.waterIntake / goals.dailyWaterGoal) * 100).clamp(0, 100);
    if (waterPct >= 100) {
      messages.add(_ProgressMessage(
        'Water goal complete! 💧',
        AppConstants.waterColor,
        Icons.water_drop_outlined,
      ));
    } else {
      messages.add(_ProgressMessage(
        '${waterPct.toStringAsFixed(0)}% of water goal done',
        AppConstants.waterColor,
        Icons.water_drop_outlined,
      ));
    }

    // Steps progress
    final stepPct =
        ((latestLog.stepsCount / goals.stepGoal) * 100).clamp(0, 100);
    if (stepPct >= 100) {
      messages.add(_ProgressMessage(
        'Step goal crushed! 🏃',
        AppConstants.stepsColor,
        Icons.directions_walk_rounded,
      ));
    } else {
      final stepsLeft = goals.stepGoal - latestLog.stepsCount;
      messages.add(_ProgressMessage(
        '$stepsLeft steps to go 👟',
        AppConstants.stepsColor,
        Icons.directions_walk_rounded,
      ));
    }

    return Column(
      children: messages.map((msg) {
        return Container(
          width: double.infinity,
          margin:  EdgeInsets.only(bottom: 8),
          padding:
               EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: msg.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: msg.color.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(msg.icon, color: msg.color, size: 20),
               SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg.text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ──────────────────────────────────────────────
  // GOAL CARD
  // ──────────────────────────────────────────────

  double calculateProgress(double start, double current, double target) {
    if (start == target) return 1.0;

    double progress;

    if (target < start) {
      // Weight loss
      progress = (start - current) / (start - target);
    } else {
      // Weight gain
      progress = (current - start) / (target - start);
    }

    return progress.clamp(0.0, 1.0);
  }

  Widget _buildGoalCard({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String unit,
    required Color color,
    required double? currentValue,
    required double goalValue,
    required bool enabled,
    bool isInteger = false,
    double? startValue,
  }) {
    // Calculate progress
    double progress = 0;
    if (currentValue != null && goalValue > 0) {
      if (title == 'Target Weight' && startValue != null && startValue > 0) {
        progress = calculateProgress(startValue, currentValue, goalValue);
      } else {
        progress = (currentValue / goalValue).clamp(0.0, 1.0);
      }
    }

    return Container(
      padding:  EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
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
                padding:  EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
               SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                      ),
                    ),
                    if (!enabled && currentValue != null)
                      Text(
                        'Current: ${isInteger ? currentValue.toInt() : currentValue.toStringAsFixed(1)} $unit',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppConstants.textLight,
                        ),
                      ),
                  ],
                ),
              ),
              if (enabled)
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: !isInteger),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    decoration: InputDecoration(
                      suffixText: unit,
                      suffixStyle: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppConstants.textLight,
                      ),
                      contentPadding:  EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: color.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color, width: 1.5),
                      ),
                    ),
                  ),
                )
              else
                Text(
                  isInteger
                      ? '${goalValue.toInt()}'
                      : goalValue.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
            ],
          ),

          // Progress bar (when not editing)
          if (!enabled && currentValue != null) ...[
             SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                    ),
                  ),
                ),
                 SizedBox(width: 10),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressMessage {
  final String text;
  final Color color;
  final IconData icon;

  _ProgressMessage(this.text, this.color, this.icon);
}
