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
    },
    SetOptions(merge: true), 
    );
  }

  Stream<QuerySnapshot> getUserRuns(String userId) {
    return _firestore
        .collection('runs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 🟢 1. ดึงข้อมูลรายวันมาแสดง (ย้ายเข้ามาอยู่ในคลาสแล้ว)
  Future<Map<String, dynamic>?> getDailyStats(
    String userId,
    String dateString,
  ) async {
    try {
      final doc =
          await _firestore // ใช้ _firestore ที่ประกาศไว้ด้านบน
              .collection('users')
              .doc(userId)
              .collection('daily_stats')
              .doc(dateString) // ใช้ YYYY-MM-DD เป็น Document ID
              .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("Error getting daily stats: $e");
      return null;
    }
  }

  // 🟢 2. อัปเดตข้อมูลรายวัน (ย้ายเข้ามาอยู่ในคลาสแล้ว)
  Future<void> updateDailyStats({
    required String userId,
    required String dateString,
    required double distance,
    required int steps,
    required double kcal,
    required int seconds,
  }) async {
    try {
      await _firestore // ใช้ _firestore ที่ประกาศไว้ด้านบน
          .collection('users')
          .doc(userId)
          .collection('daily_stats')
          .doc(dateString) // ใช้ YYYY-MM-DD เป็น Document ID
          .set(
            {
              'distance': distance,
              'steps': steps,
              'kcal': kcal,
              'seconds': seconds,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          ); // merge: true เพื่ออัปเดตค่าเก่า ไม่ใช่ลบเขียนใหม่
    } catch (e) {
      print("Error updating daily stats: $e");
      rethrow; // ใช้ rethrow ตามหลัก Dart ที่ดีกว่า throw e
    }
  }

  Future<QuerySnapshot> getPaginatedUserRuns(
    String userId, {
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) {
    // สร้าง Query พื้นฐาน: หาของ user คนนี้, เรียงจากล่าสุดไปเก่าสุด, ดึงมาแค่จำนวน limit (ค่าเริ่มต้นคือ 10)
    var query = _firestore
        .collection('runs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    // ถ้ามีการส่ง "เอกสารใบสุดท้าย" (lastDocument) มาด้วย ให้เริ่มดึง "ต่อจาก" ใบนั้น
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    // คืนค่าเป็น Future ไม่ใช่ Stream เพราะเราต้องการดึงเป็นรอบๆ ไม่ได้ดึงตลอดเวลา
    return query.get();
  }

  // 🟢 ฟังก์ชันใหม่: นับจำนวนประวัติการวิ่ง "ของจริง" จากคอลเลกชัน runs
  Future<int> getTotalRunsCount(String userId) async {
    try {
      final query = _firestore.collection('runs').where('userId', isEqualTo: userId);
      // ใช้คำสั่ง .count() เพื่อให้ฝั่ง Server นับจำนวนให้โดยไม่ดึงข้อมูล
      final aggregateQuery = await query.count().get(); 
      return aggregateQuery.count ?? 0;
    } catch (e) {
      print("Error counting runs: $e");
      return 0;
    }
  }
} 


