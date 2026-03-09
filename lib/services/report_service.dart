import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> reportPost({
    required String postId,
    required String postOwnerId,
    required String reason,
    String detail = '',
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final existingReport = await FirebaseFirestore.instance
        .collection('reports')
        .where('postId', isEqualTo: postId)
        .where('reporterId', isEqualTo: uid)
        .get();

    if (existingReport.docs.isNotEmpty) {
      throw Exception('You already reported this post');
    }

    await FirebaseFirestore.instance.collection('reports').add({
      'postId': postId,
      'postOwnerId': postOwnerId,
      'reporterId': uid,
      'reason': reason,
      'detail': detail,
      'status': 'pending',
      'create_timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> ignoreReport(String reportId) async {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).update(
      {'status': 'ignored'},
    );
  }

  static Future<void> deletePostFromReport(
    String reportId,
    String postId,
  ) async {
    await _firestore.collection('posts').doc(postId).delete();

    await _firestore.collection('reports').doc(reportId).update({
      'status': 'post_deleted',
    });
  }
}
