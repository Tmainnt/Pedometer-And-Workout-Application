import 'package:cloud_firestore/cloud_firestore.dart';

class RunRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveRun({
    required String userId,
    required double distance,
    required int duration,
    required double calories,
    required String pace,
    required List<Map<String, double>> route,
    required int steps,
  }) async {
    await _firestore.collection('runs').add({
      'userId': userId,
      'distance': distance,
      'duration': duration,
      'calories': calories,
      'pace': pace,
      'route': route,
      'steps': steps,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(userId).set({
      'user_total_distance': FieldValue.increment(distance),
      'user_total_calories': FieldValue.increment(calories),
      'user_total_step': FieldValue.increment(steps),
      'user_total_time': FieldValue.increment(duration),
      'user_total_runs': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getUserRuns(String userId) {
    return _firestore
        .collection('runs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getDailyStats(String userId, String dateString) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).collection('daily_stats').doc(dateString).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      print("Error getting daily stats: $e");
      return null;
    }
  }

  Future<void> updateDailyStats({
    required String userId,
    required String dateString,
    required double distance,
    required int steps,
    required double kcal,
    required int seconds,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).collection('daily_stats').doc(dateString).set({
        'distance': distance,
        'steps': steps,
        'kcal': kcal,
        'seconds': seconds,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating daily stats: $e");
      rethrow;
    }
  }

  // 🟢 1. ฟังก์ชันนับจำนวน (รองรับ Sort และ Filter)
  Future<int> getTotalRunsCount(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String distanceFilter = 'all',
  }) async {
    try {
      var query = _firestore.collection('runs').where('userId', isEqualTo: userId);

      // กรองระยะทาง
      if (distanceFilter == 'light') {
        query = query.where('distance', isLessThan: 5);
      } else if (distanceFilter == 'medium') {
        query = query.where('distance', isGreaterThanOrEqualTo: 5).where('distance', isLessThanOrEqualTo: 10);
      } else if (distanceFilter == 'long') {
        query = query.where('distance', isGreaterThan: 10);
      }

      // กรองวันที่
      if (startDate != null && endDate != null) {
        DateTime startOfDay = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        DateTime endOfEndDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        Timestamp startTs = Timestamp.fromDate(startOfDay);
        Timestamp endTs = Timestamp.fromDate(endOfEndDay);

        query = query.where('timestamp', isGreaterThanOrEqualTo: startTs).where('timestamp', isLessThanOrEqualTo: endTs);
      }

      final aggregateQuery = await query.count().get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      print("Error counting runs: $e");
      return 0;
    }
  }

  // 🟢 2. ฟังก์ชันดึงข้อมูล (รองรับ Sort และ Filter)
  Future<QuerySnapshot> getPaginatedUserRuns(
    String userId, {
    DocumentSnapshot? lastDocument,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'timestamp',
    String distanceFilter = 'all',
  }) {
    var query = _firestore.collection('runs').where('userId', isEqualTo: userId);

    // 1. กรองระยะทาง
    if (distanceFilter == 'light') {
      query = query.where('distance', isLessThan: 5);
    } else if (distanceFilter == 'medium') {
      query = query.where('distance', isGreaterThanOrEqualTo: 5).where('distance', isLessThanOrEqualTo: 10);
    } else if (distanceFilter == 'long') {
      query = query.where('distance', isGreaterThan: 10);
    }

    // 2. กรองวันที่
    if (startDate != null && endDate != null) {
      DateTime startOfDay = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
      DateTime endOfEndDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      Timestamp startTs = Timestamp.fromDate(startOfDay);
      Timestamp endTs = Timestamp.fromDate(endOfEndDay);

      query = query.where('timestamp', isGreaterThanOrEqualTo: startTs).where('timestamp', isLessThanOrEqualTo: endTs);
    }

    // 3. จัดเรียง
    query = query.orderBy(sortBy, descending: true).limit(limit);

    // 4. แบ่งหน้า
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.get();
  }
}