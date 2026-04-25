import 'package:flutter/material.dart';

/// App-wide constants — soft pastel wellness aesthetic.
class AppConstants {
  // ── Water Goal ──
  static const double waterGoalLiters = 3.0;

  // ── Soft Pastel Color Palette ──
  static const Color primaryColor = Color(0xFF4ECDC4);    // Teal
  static const Color secondaryColor = Color(0xFF87CEEB);   // Sky blue
  static const Color accentColor = Color(0xFFFFB5A7);      // Soft peach
  static const Color surfaceColor = Color(0xFFF8FFFE);     // Off-white tinted
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFF5F9F8);
  static const Color errorColor = Color(0xFFE57373);

  // Health metric card colors (soft pastels)
  static const Color weightColor = Color(0xFF81D4FA);      // Soft blue
  static const Color bmiColor = Color(0xFFA5D6A7);         // Soft green
  static const Color waterColor = Color(0xFF80DEEA);       // Aqua
  static const Color stepsColor = Color(0xFFFFAB91);       // Soft coral
  static const Color sleepColor = Color(0xFFCE93D8);       // Soft purple
  static const Color moodColor = Color(0xFFFFCC80);        // Soft amber
  static const Color stressColor = Color(0xFFEF9A9A);      // Soft red
  static const Color energyColor = Color(0xFFA5D6A7);      // Soft green
  static const Color chartLineColor = Color(0xFF4ECDC4);   // Teal

  // Gradient colors
  static const Color gradientStart = Color(0xFF4ECDC4);    // Teal
  static const Color gradientEnd = Color(0xFF87CEEB);      // Sky blue

  // Text colors
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMedium = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);

  // ── Padding ──
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // ── Border Radius ──
  static const double borderRadius = 20.0;
  static const double borderRadiusSmall = 14.0;
  static const double borderRadiusLarge = 28.0;
}
