import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String userId;
  final double targetWeight;
  final double dailyWaterGoal;
  final int stepGoal;
  final double sleepGoal;

  GoalModel({
    required this.userId,
    this.targetWeight = 65.0,
    this.dailyWaterGoal = 3.0,
    this.stepGoal = 10000,
    this.sleepGoal = 8.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'targetWeight': targetWeight,
      'dailyWaterGoal': dailyWaterGoal,
      'stepGoal': stepGoal,
      'sleepGoal': sleepGoal,
      'updatedAt': Timestamp.now(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      userId: map['userId'] ?? '',
      targetWeight: (map['targetWeight'] ?? 65.0).toDouble(),
      dailyWaterGoal: (map['dailyWaterGoal'] ?? 3.0).toDouble(),
      stepGoal: (map['stepGoal'] ?? 10000).toInt(),
      sleepGoal: (map['sleepGoal'] ?? 8.0).toDouble(),
    );
  }

  GoalModel copyWith({
    double? targetWeight,
    double? dailyWaterGoal,
    int? stepGoal,
    double? sleepGoal,
  }) {
    return GoalModel(
      userId: userId,
      targetWeight: targetWeight ?? this.targetWeight,
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      stepGoal: stepGoal ?? this.stepGoal,
      sleepGoal: sleepGoal ?? this.sleepGoal,
    );
  }
}
