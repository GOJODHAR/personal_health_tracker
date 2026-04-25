import 'package:cloud_firestore/cloud_firestore.dart';

/// HealthLog represents a single daily health entry stored in Firestore.
///
/// Maps directly to the 'health_logs' collection in Cloud Firestore.
class HealthLog {
  final String? id; // Firestore document ID
  final String userId;
  final DateTime date;
  final double weight;
  final double bmi;
  final double waterIntake;
  final int stepsCount;
  final double sleepHours;
  final String mood;          // '😊', '😐', or '😔'
  final int stressLevel;      // 1–10
  final String energyLevel;   // 'Low', 'Medium', or 'High'
  final int workoutDuration;  // in minutes
  final int workoutCalories;  // kcal
  final String workoutType;   // 'Running', 'Gym', etc. 

  HealthLog({
    this.id,
    required this.userId,
    required this.date,
    required this.weight,
    required this.bmi,
    required this.waterIntake,
    required this.stepsCount,
    required this.sleepHours,
    required this.mood,
    required this.stressLevel,
    required this.energyLevel,
    this.workoutDuration = 0,
    this.workoutCalories = 0,
    this.workoutType = 'None',
  });

  /// Convert HealthLog to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'bmi': bmi,
      'waterIntake': waterIntake,
      'stepsCount': stepsCount,
      'sleepHours': sleepHours,
      'mood': mood,
      'stressLevel': stressLevel,
      'energyLevel': energyLevel,
      'workoutDuration': workoutDuration,
      'workoutCalories': workoutCalories,
      'workoutType': workoutType,
    };
  }

  /// Create a HealthLog from a Firestore document snapshot
  factory HealthLog.fromMap(Map<String, dynamic> map, String documentId) {
    return HealthLog(
      id: documentId,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      weight: (map['weight'] ?? 0).toDouble(),
      bmi: (map['bmi'] ?? 0).toDouble(),
      waterIntake: (map['waterIntake'] ?? 0).toDouble(),
      stepsCount: (map['stepsCount'] ?? 0).toInt(),
      sleepHours: (map['sleepHours'] ?? 0).toDouble(),
      mood: map['mood'] ?? '😐',
      stressLevel: (map['stressLevel'] ?? 5).toInt(),
      energyLevel: map['energyLevel'] ?? 'Medium',
      workoutDuration: (map['workoutDuration'] ?? 0).toInt(),
      workoutCalories: (map['workoutCalories'] ?? 0).toInt(),
      workoutType: map['workoutType'] ?? 'None',
    );
  }
}
