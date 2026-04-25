import 'package:flutter/material.dart';
import 'dart:math';
import '../models/health_log_model.dart';
import '../services/firestore_service.dart';
import '../utils/bmi_calculator.dart';

/// HealthProvider manages health log data and notifies listeners on changes.
///
/// Provides methods to add, fetch, and delete health logs, plus
/// getters for the latest entry and weekly data for charts.
class HealthProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<HealthLog> _logs = [];
  List<HealthLog> _weeklyLogs = [];
  bool _isLoading = false;
  String? _error;

  // ── Getters ──
  List<HealthLog> get logs => _logs;
  List<HealthLog> get weeklyLogs => _weeklyLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Returns the most recent health log, or null if no logs exist.
  HealthLog? get latestLog => _logs.isNotEmpty ? _logs.first : null;

  /// Number of consecutive days (ending today or yesterday) with at least one log entry.
  int get streak {
    if (_logs.isEmpty) return 0;
    final loggedDays = _logs
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet();
    int count = 0;
    DateTime check = DateTime.now();
    DateTime today = DateTime(check.year, check.month, check.day);
    
    // If no log today, start checking from yesterday so the streak isn't visibly broken
    if (!loggedDays.contains(today)) {
      check = DateTime(check.year, check.month, check.day - 1);
    }

    while (true) {
      final day = DateTime(check.year, check.month, check.day);
      if (loggedDays.contains(day)) {
        count++;
        check = DateTime(check.year, check.month, check.day - 1);
      } else {
        break;
      }
    }
    return count;
  }

  /// Generates a simple health insight based on the latest log.
  String getSmartInsight() {
    if (_logs.isEmpty) return "Track your health to get smart insights!";
    final latestLog = _logs.first;
    
    if (latestLog.waterIntake < 2.0) {
      return "Hydration Warning: Your water intake is a bit low. Remember to drink more water! 💧";
    } else if (latestLog.sleepHours < 6.0) {
      return "Sleep Warning: You're getting less than 6 hours of sleep. Prioritize rest! 🛌";
    } else {
      return "Great job! Everything looks balanced. Keep up the healthy habits! ✨";
    }
  }

  /// Fetch all health logs for a user (ordered by date descending).
  Future<void> fetchLogs(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _logs = await _firestoreService.getHealthLogs(userId);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch health logs: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Fetch the last 7 days of health logs for the weekly chart.
  Future<void> fetchWeeklyLogs(String userId) async {
    try {
      _weeklyLogs = await _firestoreService.getWeeklyLogs(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching weekly logs: $e');
    }
  }

  /// Add a new health log entry and refresh the logs list.
  Future<bool> addHealthLog(HealthLog log) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.addHealthLog(log);
      // Refresh logs after adding
      await fetchLogs(log.userId);
      await fetchWeeklyLogs(log.userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to add health log: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Delete a health log entry by its Firestore document ID.
  Future<bool> deleteLog(String logId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.deleteHealthLog(logId);
      // Refresh logs after deletion
      await fetchLogs(userId);
      await fetchWeeklyLogs(userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete log: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Update workout data for today's health log. If none exists, creates a fresh one.
  Future<bool> updateWorkoutForToday({
    required String userId,
    required String type,
    required int duration,
    required int calories,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      
      // Try to find a health log for today
      HealthLog? todayLog;
      for (final log in _logs) {
        final logDate = DateTime(log.date.year, log.date.month, log.date.day);
        if (logDate.isAtSameMomentAs(todayStart)) {
          todayLog = log;
          break;
        }
      }

      final finalCalories = calories <= 0 ? duration * 5 : calories;

      if (todayLog != null) {
        // Update existing log
        final updatedLog = HealthLog(
          id: todayLog.id,
          userId: todayLog.userId,
          date: todayLog.date,
          weight: todayLog.weight,
          bmi: todayLog.bmi,
          waterIntake: todayLog.waterIntake,
          stepsCount: todayLog.stepsCount,
          sleepHours: todayLog.sleepHours,
          mood: todayLog.mood,
          stressLevel: todayLog.stressLevel,
          energyLevel: todayLog.energyLevel,
          workoutDuration: todayLog.workoutDuration + duration, // accumulate
          workoutCalories: todayLog.workoutCalories + finalCalories,
          workoutType: todayLog.workoutDuration > 0 ? '${todayLog.workoutType}, $type' : type,
        );
        await _firestoreService.updateHealthLog(updatedLog);
      } else {
        // Create new minimal log with just the workout info
        // (the user hasn't put in their daily weight/water/etc yet)
        
        // Use latest known weight/bmi if available, otherwise 0
        final lw = latestLog?.weight ?? 0.0;
        final lb = latestLog?.bmi ?? 0.0;
        
        final newLog = HealthLog(
          userId: userId,
          date: now,
          weight: lw,
          bmi: lb,
          waterIntake: 0.0,
          stepsCount: 0,
          sleepHours: 0.0,
          mood: '😐',
          stressLevel: 5,
          energyLevel: 'Medium',
          workoutDuration: duration,
          workoutCalories: finalCalories,
          workoutType: type,
        );
        await _firestoreService.addHealthLog(newLog);
      }

      await fetchLogs(userId);
      await fetchWeeklyLogs(userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to save workout: $e');
      _setLoading(false);
      return false;
    }
  }

  // ── Private helpers ──

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Seed 7 days of realistic demo data for testing.
  Future<bool> seedTestData(String userId, double heightCm) async {
    _setLoading(true);
    _clearError();

    final random = Random();
    final moods = ['😊', '😊', '😐', '😊', '😊', '😐', '😊'];
    final energies = ['High', 'Medium', 'High', 'Medium', 'High', 'High', 'High'];
    const baseWeight = 72.0;

    try {
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        // Weight trends down gradually (72 → ~68)
        final weight = baseWeight - (6 - i) * 0.6 + (random.nextDouble() - 0.5) * 0.4;
        final bmi = BmiCalculator.calculateBmi(weight, heightCm);
        // Water intake between 1.5 and 3.5 liters
        final water = 1.5 + random.nextDouble() * 2.0;
        // Steps between 4000 and 12000
        final steps = 4000 + random.nextInt(8000);
        // Sleep between 5.5 and 8.5 hours
        final sleep = 5.5 + random.nextDouble() * 3.0;
        // Stress decreasing over the week (7 → 3)
        final stress = (7 - (6 - i) * 0.6 + random.nextInt(2)).clamp(1, 10).toInt();

        final log = HealthLog(
          userId: userId,
          date: date,
          weight: double.parse(weight.toStringAsFixed(1)),
          bmi: bmi,
          waterIntake: double.parse(water.toStringAsFixed(1)),
          stepsCount: steps,
          sleepHours: double.parse(sleep.toStringAsFixed(1)),
          mood: moods[6 - i],
          stressLevel: stress,
          energyLevel: energies[6 - i],
          workoutDuration: i % 2 == 0 ? 30 + random.nextInt(30) : 0,
          workoutCalories: i % 2 == 0 ? 200 + random.nextInt(200) : 0,
          workoutType: i % 2 == 0 ? (i % 4 == 0 ? 'Running' : 'Yoga') : 'None',
        );

        await _firestoreService.addHealthLog(log);
      }

      // Refresh logs
      await fetchLogs(userId);
      await fetchWeeklyLogs(userId);
      debugPrint('✅ 7 days of test data seeded!');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to seed test data: ${e.toString()}');
      debugPrint('⚠️ Seed error: $e');
      _setLoading(false);
      return false;
    }
  }
}
