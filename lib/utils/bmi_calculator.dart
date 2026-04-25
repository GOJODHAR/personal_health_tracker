
class BmiCalculator {

  static double calculateBmi(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }


  static String getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }


  static int getBmiCategoryColor(double bmi) {
    if (bmi < 18.5) return 0xFF42A5F5; // Blue - Underweight
    if (bmi < 25.0) return 0xFF66BB6A; // Green - Normal
    if (bmi < 30.0) return 0xFFFFA726; // Orange - Overweight
    return 0xFFEF5350; // Red - Obese
  }
}
