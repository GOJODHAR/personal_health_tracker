import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/health_provider.dart';
import '../models/health_log_model.dart';
import '../models/goal_model.dart';
import '../utils/constants.dart';
import '../utils/bmi_calculator.dart';
import 'add_health_data_screen.dart';
import 'add_workout_screen.dart';
import 'goals_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'health_plan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    if (authProvider.currentUserId != null) {
      await healthProvider.fetchLogs(authProvider.currentUserId!);
      await goalProvider.fetchGoals(authProvider.currentUserId!);
    }
  }

  void _goToDashboard() {
    setState(() => _currentIndex = 0);
  }


  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      HistoryScreen(onBackToDashboard: _goToDashboard),
      const SizedBox(), // FAB placeholder
      GoalsScreen(onBackToDashboard: _goToDashboard),
      ProfileScreen(onBackToDashboard: _goToDashboard),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : (_currentIndex > 4 ? 0 : _currentIndex),
        children: screens,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppConstants.gradientStart, AppConstants.gradientEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => _showAddOptions(context),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add_rounded,
                  size: 28, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add Entry',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Motivational strip ──
          Consumer<HealthProvider>(
            builder: (context, hp, _) {
              final streakCount = hp.streak;
              String motivationText;
              if (streakCount >= 7) {
                motivationText = '🔥 Amazing consistency! $streakCount day streak!';
              } else if (streakCount >= 3) {
                motivationText = '💪 Keep going! $streakCount day streak!';
              } else {
                motivationText = '🚀 Start your streak today!';
              }
              return Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  motivationText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.primaryColor,
                  ),
                ),
              );
            },
          ),
          // ── Bottom bar with curved notch ──
          BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            elevation: 0,
            padding: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    AppConstants.primaryColor.withValues(alpha: 0.04),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, Icons.home_rounded,
                      'Home', 0),
                  _buildNavItem(Icons.bar_chart_outlined,
                      Icons.bar_chart_rounded, 'Stats', 1),
                  const SizedBox(width: 56), // space for FAB
                  _buildNavItem(Icons.flag_outlined,
                      Icons.flag_rounded, 'Goals', 3),
                  _buildNavItem(Icons.person_outline_rounded,
                      Icons.person_rounded, 'Profile', 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // DASHBOARD CONTENT
  // ──────────────────────────────────────────────

  double _computeHealthScore(HealthLog log, GoalModel? goals) {
    if (goals == null) return 0;
    final waterPct = (log.waterIntake / goals.dailyWaterGoal).clamp(0.0, 1.0);
    final stepsPct =
        (log.stepsCount / (goals.stepGoal > 0 ? goals.stepGoal : 1))
            .clamp(0.0, 1.0);
    final sleepPct =
        (log.sleepHours / (goals.sleepGoal > 0 ? goals.sleepGoal : 1))
            .clamp(0.0, 1.0);
    final weightDiff = (log.weight - goals.targetWeight).abs();
    final weightPct =
        (1.0 - (weightDiff / (goals.targetWeight > 0 ? goals.targetWeight : 1))
                .clamp(0.0, 1.0));
    return (waterPct + stepsPct + sleepPct + weightPct) / 4 * 100;
  }

  Widget _buildDashboard() {
    return Consumer3<AuthProvider, HealthProvider, GoalProvider>(
      builder: (context, authProvider, healthProvider, goalProvider, _) {
        final user = authProvider.user;
        final latestLog = healthProvider.latestLog;
        final goals = goalProvider.goals;
        final streak = healthProvider.streak;
        final bmi = (latestLog != null && user != null)
            ? BmiCalculator.calculateBmi(latestLog.weight, user.heightCm)
            : 0.0;
        final healthScore =
            latestLog != null ? _computeHealthScore(latestLog, goals) : 0.0;

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.name ?? 'Friend'} 👋',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Let's check your health today",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Seed test data button
                    GestureDetector(
                      onTap: () async {
                        final hp = Provider.of<HealthProvider>(context, listen: false);
                        final ap = Provider.of<AuthProvider>(context, listen: false);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        
                        if (ap.currentUserId != null) {
                          final success = await hp.seedTestData(
                            ap.currentUserId!,
                            ap.user?.heightCm != null && ap.user!.heightCm > 0
                                ? ap.user!.heightCm
                                : 170.0,
                          );

                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? '✅ 7 days of test data & workouts added!'
                                      : '❌ Failed to seed data',
                                  style: GoogleFonts.poppins(fontSize: 14),
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
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.science_outlined,
                            color: AppConstants.primaryColor, size: 20),
                      ),
                    ),
                    // Avatar + actions
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 4),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppConstants.gradientStart,
                              AppConstants.gradientEnd,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.primaryColor
                                  .withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (user?.name ?? 'U')[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Hero Progress Card (dark teal) ──
                _buildProgressCard(bmi, latestLog,
                    healthScore: healthScore, streak: streak),
                const SizedBox(height: 16),

                // ── Generate Plan Button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HealthPlanScreen(
                            bmi: bmi,
                            bmiCategory: bmi > 0
                                ? (bmi < 18.5
                                    ? 'Underweight'
                                    : bmi < 25
                                        ? 'Normal'
                                        : bmi < 30
                                            ? 'Overweight'
                                            : 'Obese')
                                : 'No data',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: Text(
                      'Generate My Health Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: AppConstants.primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),


                // ── Two-column stat cards row 1: Weight + Steps ──
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Weight',
                        value: latestLog != null
                            ? latestLog.weight.toStringAsFixed(1)
                            : '--',
                        unit: 'kg',
                        color: AppConstants.weightColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.directions_walk_rounded,
                        label: 'Steps',
                        value: latestLog != null
                            ? '${latestLog.stepsCount}'
                            : '--',
                        unit: 'steps',
                        color: AppConstants.stepsColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Two-column stat cards row 2: Water + Sleep ──
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.water_drop_outlined,
                        label: 'Water',
                        value: latestLog != null
                            ? latestLog.waterIntake.toStringAsFixed(1)
                            : '--',
                        unit: 'liters',
                        color: AppConstants.waterColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.bedtime_outlined,
                        label: 'Sleep',
                        value: latestLog != null
                            ? latestLog.sleepHours.toStringAsFixed(1)
                            : '--',
                        unit: 'hours',
                        color: AppConstants.sleepColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Wellness summary (mood / stress / energy) ──
                Text(
                  'Wellness Summary',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                  ),
                ),
                const SizedBox(height: 10),
                _buildWellnessRow(latestLog),
                const SizedBox(height: 16),

                // ── Smart Health Insights ──
                Text(
                  'Smart Insight',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppConstants.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppConstants.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          healthProvider.getSmartInsight(),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Recent Workouts ──
                _buildRecentWorkouts(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentWorkouts() {
    return Consumer<HealthProvider>(
      builder: (context, hp, _) {
        final workoutLogs = hp.logs.where((log) => log.workoutDuration > 0).toList();
        if (workoutLogs.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Workouts',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
              ),
            ),
            const SizedBox(height: 10),
            ...workoutLogs.take(3).map((w) {
              IconData icon;
              Color color;
              
              // Handle multiple string types if appended
              final typeString = w.workoutType;
              final firstType = typeString.split(',').first.trim();

              switch (firstType) {
                case 'Running': icon = Icons.directions_run_rounded; color = const Color(0xFFEF5350); break;
                case 'Gym': icon = Icons.fitness_center_rounded; color = const Color(0xFF42A5F5); break;
                case 'Cycling': icon = Icons.directions_bike_rounded; color = const Color(0xFFFFB74D); break;
                case 'Yoga': icon = Icons.self_improvement_rounded; color = const Color(0xFFAB47BC); break;
                default: icon = Icons.directions_walk_rounded; color = const Color(0xFF66BB6A);
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(typeString, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark))),
                          Text('${w.workoutDuration} mins', style: GoogleFonts.poppins(fontSize: 11, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium))),
                        ],
                      ),
                    ),
                    Text('${w.workoutCalories} kcal', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: AppConstants.energyColor)),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // HERO PROGRESS CARD
  // ──────────────────────────────────────────────

  Widget _buildProgressCard(double bmi, HealthLog? latestLog,
      {double healthScore = 0, int streak = 0}) {
    String bmiCategory = 'No data';
    Color bmiCatColor = Colors.white70;
    if (bmi > 0) {
      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
        bmiCatColor = const Color(0xFF81D4FA);
      } else if (bmi < 25) {
        bmiCategory = 'Normal';
        bmiCatColor = const Color(0xFF81C784);
      } else if (bmi < 30) {
        bmiCategory = 'Overweight';
        bmiCatColor = const Color(0xFFFFB74D);
      } else {
        bmiCategory = 'Obese';
        bmiCatColor = const Color(0xFFE57373);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A9D8F),
            Color(0xFF264653),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF264653).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_rounded,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Your Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (streak > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥',
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '$streak day${streak > 1 ? 's' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: _loadData,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.refresh_rounded,
                          color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // BMI value large
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                bmi > 0 ? bmi.toStringAsFixed(1) : '--',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'BMI',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white60,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bmiCatColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bmiCategory,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: bmiCatColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Health score bar
          if (healthScore > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Health Score',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '${healthScore.toInt()}/100',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: healthScore / 100,
                backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(
                  healthScore >= 70
                      ? const Color(0xFF81C784)
                      : healthScore >= 40
                          ? const Color(0xFFFFB74D)
                          : const Color(0xFFE57373),
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 14),
          ] else
            const SizedBox(height: 4),

          // Bottom row: weight + mood summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Theme.of(context).cardColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressStat(
                  Icons.monitor_weight_outlined,
                  latestLog != null
                      ? '${latestLog.weight.toStringAsFixed(1)} kg'
                      : '-- kg',
                  'Weight',
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                _buildProgressStat(
                  Icons.water_drop_outlined,
                  latestLog != null
                      ? '${latestLog.waterIntake.toStringAsFixed(1)} L'
                      : '-- L',
                  'Water',
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                _buildProgressStat(
                  Icons.bedtime_outlined,
                  latestLog != null
                      ? '${latestLog.sleepHours.toStringAsFixed(1)}h'
                      : '-- h',
                  'Sleep',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(IconData icon, String value, String label) {
    return Flexible(
      child: Column(
        children: [
          Icon(icon, color: Colors.white60, size: 16),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // STAT CARD (clean & minimal)
  // ──────────────────────────────────────────────

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppConstants.textLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // WELLNESS ROW (mood / stress / energy)
  // ──────────────────────────────────────────────

  Widget _buildWellnessRow(HealthLog? latestLog) {
    if (latestLog == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Log data to see your wellness summary ✨',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppConstants.textLight,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildWellnessChip(
            latestLog.mood,
            'Mood',
            AppConstants.moodColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildWellnessChip(
            '${latestLog.stressLevel}/10',
            'Stress',
            AppConstants.stressColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildWellnessChip(
            latestLog.energyLevel,
            'Energy',
            AppConstants.energyColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWellnessChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────

  Widget _buildNavItem(
      IconData icon, IconData activeIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppConstants.primaryColor
                  : AppConstants.textLight,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppConstants.primaryColor
                    : AppConstants.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What would you like to track?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.health_and_safety_rounded,
                      label: 'Health Data',
                      color: AppConstants.primaryColor,
                      onTap: () async {
                        Navigator.pop(ctx);
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHealthDataScreen()));
                        _loadData();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.fitness_center_rounded,
                      label: 'Workout',
                      color: AppConstants.accentColor,
                      onTap: () async {
                        Navigator.pop(ctx);
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddWorkoutScreen()));
                        _loadData();
                      },
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

  Widget _buildActionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
