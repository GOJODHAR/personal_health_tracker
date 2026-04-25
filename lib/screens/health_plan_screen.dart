import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class HealthPlanScreen extends StatelessWidget {
  final double bmi;
  final String bmiCategory;

  const HealthPlanScreen({
    super.key,
    required this.bmi,
    required this.bmiCategory,
  });

  Map<String, dynamic> _getPlanData() {
    if (bmi < 18.5) {
      return {
        'goal': 'Gain healthy weight + build muscle',
        'diet_tips': [
          'Eat more frequently: 5–6 meals/day',
          'Protein-rich foods: eggs, chicken, paneer, lentils',
          'Healthy carbs: rice, potatoes, oats, whole wheat',
          'Healthy fats: nuts, peanut butter, milk, ghee (in moderation)',
          'High-calorie snacks: banana shake, dry fruits',
        ],
        'diet_example':
            'Breakfast: Eggs + toast + milk\nLunch: Rice + dal + chicken/paneer\nSnack: Banana shake + peanuts\nDinner: Chapati + sabzi + curd',
        'workout': [
          'Strength training (3–4 days/week):\n - Push-ups\n - Squats\n - Dumbbell exercises',
          'Light cardio (1–2 times/week only)',
        ],
        'habits': [
          'Sleep: 7–9 hours',
          'Avoid skipping meals',
          'Track weight weekly',
        ],
        'color': const Color(0xFF81D4FA),
      };
    } else if (bmi < 25) {
      return {
        'goal': 'Maintain fitness + improve strength',
        'diet_tips': [
          'Balanced diet (protein + carbs + fats)',
          'Include fruits & vegetables daily',
          'Whole grains (roti, oats, brown rice)',
          'Lean protein (eggs, fish, dal)',
          'Limit junk + sugary drinks',
        ],
        'diet_example':
            'Breakfast: Oats + fruits\nLunch: Roti + sabzi + dal\nSnack: Fruits / nuts\nDinner: Light meal (salad + protein)',
        'workout': [
          'Cardio (3–4 days/week):\n - Running / cycling / brisk walking',
          'Strength training (2–3 days/week):\n - Full body workouts',
        ],
        'habits': [
          '8,000–10,000 steps/day',
          'Stay hydrated (2–3L water)',
          'Consistent sleep schedule',
        ],
        'color': const Color(0xFF81C784),
      };
    } else {
      return {
        'goal': 'Fat loss + improve metabolism',
        'diet_tips': [
          'Calorie-controlled diet',
          'High protein + low junk',
          'Vegetables (fill 50% plate)',
          'Lean protein (chicken, eggs, dal)',
          'Whole grains (avoid white bread/rice excess)',
          '❌ Avoid: Fried food, Sugary drinks, Late-night eating',
        ],
        'diet_example':
            'Breakfast: Boiled eggs + oats\nLunch: Roti + sabzi + dal\nSnack: Fruits / green tea\nDinner: Light (salad + protein)',
        'workout': [
          'Cardio (4–5 days/week):\n - Brisk walking (30–45 min)\n - Cycling / swimming',
          'Strength training (2–3 days/week):\n - Bodyweight exercises',
        ],
        'habits': [
          '8,000+ steps/day',
          'Drink 2–3L water',
          'Sleep 7–8 hours',
          'Eat slowly & mindfully',
        ],
        'color': bmi < 30 ? const Color(0xFFFFB74D) : const Color(0xFFE57373),
      };
    }
  }

  String _getRandomProTip() {
    final tips = [
      "Consistency is more important than perfection. Keep going!",
      "Hydration boosts your metabolism and keeps your energy up.",
      "A 15-minute walk after meals helps with blood sugar spikes.",
      "Don't rely on the scale alone; take progress photos and measure your energy levels.",
      "Getting 7-8 hours of sleep is crucial for muscle recovery and weight control."
    ];
    tips.shuffle();
    return tips.first;
  }

  @override
  Widget build(BuildContext context) {
    if (bmi <= 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Health Plan')),
        body: Center(
          child: Text(
            'Please log your weight and height to generate a plan.',
            style: GoogleFonts.poppins(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } // Handle no data

    final planData = _getPlanData();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Your Health Plan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic text based on real BMI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: planData['color'].withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: planData['color'].withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.monitor_weight_outlined, color: planData['color'], size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Based on your BMI of ${bmi.toStringAsFixed(1)}, you fall into the $bmiCategory category.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppConstants.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Goal
            Text(
              '🎯 Main Goal',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              planData['goal'],
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Diet Plan
            _buildSectionHeader('🍽️ Diet Plan', Icons.restaurant_menu),
            ...List<Widget>.from(planData['diet_tips'].map((tip) => _buildListItem(tip, isDark))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('👉 Example Day:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(planData['diet_example'], style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Workout Plan
            _buildSectionHeader('🏋️ Workout Plan', Icons.fitness_center),
            ...List<Widget>.from(planData['workout'].map((w) => _buildListItem(w, isDark))),
            const SizedBox(height: 24),

            // Habits
            _buildSectionHeader('🔁 Key Habits', Icons.loop_rounded),
            ...List<Widget>.from(planData['habits'].map((h) => _buildListItem(h, isDark))),
            const SizedBox(height: 24),

            // Pro Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppConstants.gradientStart, AppConstants.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🧠 Pro Tip',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getRandomProTip(),
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildListItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.check_circle_rounded, color: AppConstants.primaryColor, size: 16),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppConstants.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
