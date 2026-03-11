import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final DateTime createTimestamp;
  final String deletedBy;
  final String detail;
  final bool isRead;
  final String postId;
  final String reason;
  final String type;

  NotificationModel({
    required this.id,
    required this.createTimestamp,
    required this.deletedBy,
    required this.detail,
    required this.isRead,
    required this.postId,
    required this.reason,
    required this.type,
  });

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return NotificationModel(
      id: doc.id,
      createTimestamp: data['create_timestamp'] != null
          ? (data['create_timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      deletedBy: data['deletedBy'] ?? '',
      detail: data['detail'] ?? '',
      isRead: data['isRead'] ?? false,
      postId: data['postID'] ?? '',
      reason: data['reason'] ?? '',
      type: data['type'] ?? '',
    );
  }
}
