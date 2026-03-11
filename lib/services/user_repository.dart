import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser({
    required String uid,
    required String username,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'profile_image': '', 
        'created_at': FieldValue.serverTimestamp(),
        'step_goal': 10000, 
      });
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }
}
