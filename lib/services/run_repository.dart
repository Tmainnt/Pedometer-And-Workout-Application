import 'package:cloud_firestore/cloud_firestore.dart';

class RunRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveRun({
    required String userId,
    required double distance,
    required int duration,
    required double calories,
    required String pace,
  }) async {
    await _firestore.collection('runs').add({
      'userId': userId,
      'distance': distance,
      'duration': duration,
      'calories': calories,
      'pace': pace,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserRuns(String userId) {
    return _firestore
        .collection('runs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
