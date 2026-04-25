import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../models/health_log_model.dart';
import '../utils/constants.dart';
import '../utils/bmi_calculator.dart';

class AddHealthDataScreen extends StatefulWidget {
   const AddHealthDataScreen({super.key});

  @override
  State<AddHealthDataScreen> createState() => _AddHealthDataScreenState();
}

class _AddHealthDataScreenState extends State<AddHealthDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _waterController = TextEditingController();
  final _stepsController = TextEditingController();
  final _sleepController = TextEditingController();

  String _selectedMood = '😊';
  double _stressLevel = 5;
  String _energyLevel = 'Medium';

  @override
  void dispose() {
    _weightController.dispose();
    _waterController.dispose();
    _stepsController.dispose();
    _sleepController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final user = authProvider.user;

    // Duplicate-entry guard: warn if there is already an entry for today
    final existingLog = healthProvider.latestLog;
    if (existingLog != null) {
      final today = DateTime.now();
      final logDate = existingLog.date;
      final sameDay = today.year == logDate.year &&
          today.month == logDate.month &&
          today.day == logDate.day;
      if (sameDay && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            title: Text('Already logged today',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            content: Text(
              'You already have an entry for today. Add another one anyway?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style:
                        GoogleFonts.poppins(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Add Anyway',
                    style:
                        GoogleFonts.poppins(color: AppConstants.primaryColor)),
              ),
            ],
          ),
        );
        if (proceed != true) return;
      }
    }

    final weight = double.parse(_weightController.text.trim());
    final heightCm = user?.heightCm ?? 170.0;

    final log = HealthLog(
      userId: authProvider.currentUserId!,
      date: DateTime.now(),
      weight: weight,
      bmi: BmiCalculator.calculateBmi(weight, heightCm),
      waterIntake: double.parse(_waterController.text.trim()),
      stepsCount: int.parse(_stepsController.text.trim()),
      sleepHours: double.parse(_sleepController.text.trim()),
      mood: _selectedMood,
      stressLevel: _stressLevel.round(),
      energyLevel: _energyLevel,
    );

    final success = await healthProvider.addHealthLog(log);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                 Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                 SizedBox(width: 10),
                Text('Health data saved! 🎉',
                    style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
            backgroundColor: AppConstants.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                 Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                 SizedBox(width: 10),
                Expanded(
                  child: Text(
                    healthProvider.error ?? 'Failed to save data. Please try again.',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:  EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SizedBox(height: 16),

                // ── App bar ──
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding:  EdgeInsets.all(10),
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
                     SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Health Data',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                          ),
                        ),
                        Text(
                          'Record your daily metrics 📋',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                 SizedBox(height: 28),

                // ── Weight ──
                _buildInputCard(
                  icon: Icons.monitor_weight_outlined,
                  iconColor: AppConstants.weightColor,
                  label: 'Weight',
                  hint: '70.5',
                  suffix: 'kg',
                  controller: _weightController,
                  keyboardType:  TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final w = double.tryParse(v);
                    if (w == null || w <= 0 || w > 500) return 'Enter valid weight (1-500 kg)';
                    return null;
                  },
                ),
                 SizedBox(height: 14),

                // ── Water Intake ──
                _buildInputCard(
                  icon: Icons.water_drop_outlined,
                  iconColor: AppConstants.waterColor,
                  label: 'Water Intake',
                  hint: '2.5',
                  suffix: 'liters',
                  controller: _waterController,
                  keyboardType:  TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final w = double.tryParse(v);
                    if (w == null || w <= 0 || w > 20) return 'Enter valid amount (0-20 L)';
                    return null;
                  },
                ),
                 SizedBox(height: 14),

                // ── Steps Count ──
                _buildInputCard(
                  icon: Icons.directions_walk_rounded,
                  iconColor: AppConstants.stepsColor,
                  label: 'Steps Count',
                  hint: '8000',
                  suffix: 'steps',
                  controller: _stepsController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final s = int.tryParse(v);
                    if (s == null || s < 0 || s > 200000) return 'Enter valid steps (0-200000)';
                    return null;
                  },
                ),
                 SizedBox(height: 14),

                // ── Sleep Hours ──
                _buildInputCard(
                  icon: Icons.bedtime_outlined,
                  iconColor: AppConstants.sleepColor,
                  label: 'Sleep Hours',
                  hint: '7.5',
                  suffix: 'hrs',
                  controller: _sleepController,
                  keyboardType:  TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final s = double.tryParse(v);
                    if (s == null || s <= 0 || s > 24) return 'Enter valid hours (0-24)';
                    return null;
                  },
                ),
                 SizedBox(height: 20),

                // ── Mood Selection ──
                _buildSectionLabel('How are you feeling?'),
                 SizedBox(height: 10),
                _buildMoodSelector(),
                 SizedBox(height: 20),

                // ── Stress Level ──
                _buildSectionLabel('Stress Level'),
                 SizedBox(height: 10),
                _buildStressSlider(),
                 SizedBox(height: 20),

                // ── Energy Level ──
                _buildSectionLabel('Energy Level'),
                 SizedBox(height: 10),
                _buildEnergyChips(),
                 SizedBox(height: 32),

                // ── Save button ──
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusLarge),
                      gradient:  LinearGradient(
                        colors: [
                          AppConstants.gradientStart,
                          AppConstants.gradientEnd,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset:  Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _saveData,
                      icon:  Icon(Icons.save_rounded,
                          color: Colors.white, size: 20),
                      label: Text(
                        'Save Data',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding:  EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusLarge),
                        ),
                      ),
                    ),
                  ),
                ),
                 SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // INPUT CARD (reusable)
  // ──────────────────────────────────────────────

  Widget _buildInputCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
    required String suffix,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.number,
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
      child: Row(
        children: [
          Container(
            padding:  EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
           SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                 SizedBox(height: 4),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:
                        GoogleFonts.poppins(color: AppConstants.textLight),
                    suffixText: suffix,
                    suffixStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  validator: validator,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // MOOD SELECTOR (3 emoji buttons)
  // ──────────────────────────────────────────────

  Widget _buildMoodSelector() {
    final moods = ['😊', '😐', '😔'];
    final labels = ['Happy', 'Okay', 'Sad'];

    return Container(
      padding:  EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(moods.length, (i) {
          final selected = _selectedMood == moods[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedMood = moods[i]),
            child: AnimatedContainer(
              duration:  Duration(milliseconds: 200),
              padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? AppConstants.moodColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppConstants.moodColor
                      : AppConstants.textLight.withValues(alpha: 0.3),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(moods[i], style:  TextStyle(fontSize: 28)),
                   SizedBox(height: 4),
                  Text(
                    labels[i],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark)
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // STRESS SLIDER (1–10)
  // ──────────────────────────────────────────────

  Widget _buildStressSlider() {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:  EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.stressColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:  Icon(
                      Icons.speed_rounded,
                      color: AppConstants.stressColor,
                      size: 18,
                    ),
                  ),
                   SizedBox(width: 10),
                  Text(
                    'Stress',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                     EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _stressLevelColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_stressLevel.round()}/10',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _stressLevelColor,
                  ),
                ),
              ),
            ],
          ),
           SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _stressLevelColor,
              inactiveTrackColor: _stressLevelColor.withValues(alpha: 0.15),
              thumbColor: _stressLevelColor,
              overlayColor: _stressLevelColor.withValues(alpha: 0.12),
              trackHeight: 6,
              thumbShape:  RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _stressLevel,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) => setState(() => _stressLevel = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Relaxed',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppConstants.textLight)),
              Text('Very Stressed',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppConstants.textLight)),
            ],
          ),
        ],
      ),
    );
  }

  Color get _stressLevelColor {
    if (_stressLevel <= 3) return AppConstants.energyColor;  // green
    if (_stressLevel <= 6) return AppConstants.moodColor;    // amber
    return AppConstants.stressColor;                          // red
  }

  // ──────────────────────────────────────────────
  // ENERGY CHIPS (Low / Medium / High)
  // ──────────────────────────────────────────────

  Widget _buildEnergyChips() {
    final levels = ['Low', 'Medium', 'High'];
    final icons = [
      Icons.battery_1_bar_rounded,
      Icons.battery_4_bar_rounded,
      Icons.battery_full_rounded,
    ];

    return Container(
      padding:  EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
      child: Row(
        children: List.generate(levels.length, (i) {
          final selected = _energyLevel == levels[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _energyLevel = levels[i]),
              child: AnimatedContainer(
                duration:  Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  left: i == 0 ? 0 : 5,
                  right: i == levels.length - 1 ? 0 : 5,
                ),
                padding:  EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? AppConstants.energyColor.withValues(alpha: 0.15)
                      : AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? AppConstants.energyColor
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icons[i],
                      color: selected
                          ? AppConstants.energyColor
                          : AppConstants.textLight,
                      size: 22,
                    ),
                     SizedBox(height: 4),
                    Text(
                      levels[i],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark)
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // SECTION LABEL
  // ──────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
      ),
    );
  }
}
