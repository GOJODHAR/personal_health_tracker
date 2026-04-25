import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/health_log_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;



  Future<void> createUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }


  Future<UserModel?> getUserProfile(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> addHealthLog(HealthLog log) async {
    final data = log.toMap();
    debugPrint('🔥 [Firestore] Adding health log: $data');
    final docRef = await _db.collection('health_logs').add(data);
    debugPrint('🔥 [Firestore] Saved health log: ${docRef.id}');
  }

  Future<void> updateHealthLog(HealthLog log) async {
    if (log.id == null || log.id!.isEmpty) return;
    final data = log.toMap();
    debugPrint('🔥 [Firestore] Updating health log: $data');
    await _db.collection('health_logs').doc(log.id).update(data);
  }


  Future<List<HealthLog>> getHealthLogs(String userId) async {
    debugPrint('🔥 [Firestore] Fetching logs for user: $userId');

    try {
      // Try the indexed query first (userId + date ordering)
      final snapshot = await _db
          .collection('health_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      debugPrint('🔥 [Firestore] Found ${snapshot.docs.length} logs (indexed query)');
      return snapshot.docs.map((doc) {
        return HealthLog.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint('⚠️ [Firestore] Indexed query failed: $e');
      debugPrint('⚠️ [Firestore] Falling back to unordered query...');

      // Fallback: fetch without ordering (doesn't need composite index)
      try {
        final snapshot = await _db
            .collection('health_logs')
            .where('userId', isEqualTo: userId)
            .get();

        debugPrint('🔥 [Firestore] Found ${snapshot.docs.length} logs (fallback)');
        final logs = snapshot.docs.map((doc) {
          return HealthLog.fromMap(doc.data(), doc.id);
        }).toList();

        // Sort client-side instead
        logs.sort((a, b) => b.date.compareTo(a.date));
        return logs;
      } catch (e2) {
        debugPrint('❌ [Firestore] Fallback query also failed: $e2');
        rethrow;
      }
    }
  }

  /// Fetch weekly logs.
  Future<List<HealthLog>> getWeeklyLogs(String userId) async {
    try {
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      final snapshot = await _db
          .collection('health_logs')
          .where('userId', isEqualTo: userId)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        return HealthLog.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint('⚠️ [Firestore] Weekly logs query failed: $e');

      // Fallback: get all logs and filter client-side
      try {
        final snapshot = await _db
            .collection('health_logs')
            .where('userId', isEqualTo: userId)
            .get();

        final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
        final logs = snapshot.docs
            .map((doc) => HealthLog.fromMap(doc.data(), doc.id))
            .where((log) => log.date.isAfter(oneWeekAgo))
            .toList();

        logs.sort((a, b) => a.date.compareTo(b.date));
        return logs;
      } catch (e2) {
        debugPrint('❌ [Firestore] Weekly fallback also failed: $e2');
        return [];
      }
    }
  }


  Future<void> deleteHealthLog(String logId) async {
    await _db.collection('health_logs').doc(logId).delete();
  }
}
