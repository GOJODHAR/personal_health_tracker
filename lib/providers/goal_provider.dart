import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  GoalModel? _goals;
  bool _isLoading = false;

  GoalModel? get goals => _goals;
  bool get isLoading => _isLoading;

  /// Fetch goals from the user's document (stored as 'goals' field).
  /// This avoids needing separate Firestore security rules for a goals collection.
  Future<void> fetchGoals(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('goals') && data['goals'] is Map) {
          final goalsMap =
              Map<String, dynamic>.from(data['goals'] as Map);
          goalsMap['userId'] = userId;
          _goals = GoalModel.fromMap(goalsMap);
        } else {
          // No goals yet — create defaults
          _goals = GoalModel(userId: userId);
          await _saveToFirestore(userId);
        }
      } else {
        _goals = GoalModel(userId: userId);
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching goals: $e');
      _goals = GoalModel(userId: userId);
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Save goals to the user's document using merge.
  Future<bool> saveGoals(GoalModel goals) async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = goals;
      await _saveToFirestore(goals.userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('⚠️ Error saving goals: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveToFirestore(String userId) async {
    final goalsData = _goals!.toMap();
    goalsData.remove('userId'); // don't nest userId inside goals
    await _db.collection('users').doc(userId).set(
      {'goals': goalsData},
      SetOptions(merge: true),
    );
    debugPrint('✅ Goals saved to users/$userId');
  }
}
