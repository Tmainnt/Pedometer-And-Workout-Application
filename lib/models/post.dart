import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String _UID = '';
  String _content = '';
  String _feeling = '';
  String _imageUrl = '';
  int _totalLike = 0;
  int _totalComment = 0;
  DateTime _timestamp = DateTime(0);

  Post(Map<String, dynamic> userPostData) {
    _UID = userPostData['postBy_UID'];
    _content = userPostData['content'];
    _feeling = userPostData['feeling'];
    _imageUrl = userPostData['imageUrl'];
    _timestamp = userPostData['create_timestamp'].toDate();
    _totalLike = userPostData['total_like'];
    _totalComment = userPostData['total_comment'];
  }

  String get UID => _UID;
  String get content => _content;
  String get feeling => _feeling;
  String get imageUrl => _imageUrl;
  int get totalLike => _totalLike;
  int get totalComment => _totalComment;
  DateTime get timestamp => _timestamp;
}
