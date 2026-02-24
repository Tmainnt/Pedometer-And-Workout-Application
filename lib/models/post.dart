import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedometer_application/services/firestore_service.dart';

class Post {
  final String? _postID;
  final String _UID;
  String _content;
  String _feeling;
  String _imageUrl;
  int _totalLike;
  int _totalComment;
  DateTime _timestamp; // เวลาที่โพสต์ถูกสร้างครั้งแรก เก็บแยกกับการแก้ไข
  DateTime _updateTimestamp; // เวลาที่โพสต์ถูกแก้ไข เวลาตรงนี้จะเปลี่ยน
  FirestoreService firestoreService = FirestoreService();

  Post({
    required String postID,
    required String UID,
    required String content,
    required String feeling,
    required String imageUrl,
    required int totalLike,
    required int totalComment,
    required DateTime timestamp,
    required DateTime updateTimestamp,
  }) : _postID = postID,
       _UID = UID,
       _content = content,
       _feeling = feeling,
       _imageUrl = imageUrl,
       _totalLike = totalLike,
       _totalComment = totalComment,
       _timestamp = timestamp,
       _updateTimestamp = updateTimestamp;

  factory Post.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return Post(
      postID: doc.id,
      UID: data['postBy_UID'] ?? '',
      content: data['content'] ?? '',
      feeling: data['feeling'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      totalLike: data['total_like'] ?? 0,
      totalComment: data['total_comment'] ?? 0,
      timestamp: data['create_timestamp'] != null
          ? (data['create_timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      updateTimestamp: data['update_timestamp'] != null
          ? (data['update_timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  String? get postID => _postID;
  String get UID => _UID;
  String get content => _content;
  String get feeling => _feeling;
  String get imageUrl => _imageUrl;
  int get totalLike => _totalLike;
  int get totalComment => _totalComment;
  DateTime get timestamp => _timestamp;
  DateTime get updateTimestamp => _updateTimestamp;

  void updateWhenEdit() {
    _updateTimestamp = DateTime.now();
    firestoreService.updatePost(this);
  }

  set updateContent(String newContent) {
    _content = newContent;
    updateWhenEdit();
  }

  set updateFeeling(String feeling) {
    _feeling = feeling;
    updateWhenEdit();
  }

  set updateImageUrl(String url) {
    _imageUrl = url;
    updateWhenEdit();
  }
}
